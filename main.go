package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"reflect"
	"runtime"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	_ "github.com/lib/pq"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Custom error types
type AppError struct {
	Err     error
	Message string
	Context string
}

func (e *AppError) Error() string {
	return fmt.Sprintf("%s: %s (%s)", e.Message, e.Err, e.Context)
}

// Error counter
var errorTotal = promauto.NewCounterVec(prometheus.CounterOpts{
	Name: "errors_total",
	Help: "Total number of errors",
}, []string{"error_type", "error_message", "function", "error_code"})

// Error histogram (for latency)
var errorLatency = promauto.NewHistogramVec(prometheus.HistogramOpts{
	Name:    "error_latency_seconds",
	Help:    "Error latency in seconds",
	Buckets: prometheus.ExponentialBuckets(0.001, 2, 10),
}, []string{"error_type", "error_message", "function", "error_code"})

func handleError(err error, functionName string, errorCode string, start time.Time) {
	var errType string
	var errMsg string
	if appErr, ok := err.(*AppError); ok {
		errType = appErr.Message
		errMsg = appErr.Error()
	} else {
		errType = reflect.TypeOf(err).String()
		errMsg = err.Error()
	}

	errorTotal.WithLabelValues(errType, errMsg, functionName, errorCode).Inc()
	errorLatency.WithLabelValues(errType, errMsg, functionName, errorCode).Observe(time.Since(start).Seconds())
	log.Printf("Error: %v", err)
}

type DBConfig struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type Data struct {
	ID   int    `json:"id"`
	Data string `json:"data"`
}

var dbConfig DBConfig
var region = os.Getenv("AWS_REGION")
var dbHost = os.Getenv("DB_ENDPOINT_READER")
var dbPort = os.Getenv("DB_PORT")
var dbName = os.Getenv("DB_NAME")
var tableName = os.Getenv("TABLE_NAME")

// Prometheus metrics
var funcCount = promauto.NewCounterVec(prometheus.CounterOpts{
	Name: "function_calls_total",
	Help: "Total number of function calls",
}, []string{"function"})

var memoryUsage = promauto.NewHistogramVec(prometheus.HistogramOpts{
	Name:    "memory_usage_bytes",
	Help:    "Memory usage in bytes",
	Buckets: prometheus.ExponentialBuckets(1024, 2, 10),
}, []string{"function"})

var cpuUtilization = promauto.NewHistogramVec(prometheus.HistogramOpts{
	Name:    "cpu_utilization_seconds",
	Help:    "CPU utilization in seconds",
	Buckets: prometheus.ExponentialBuckets(0.001, 2, 10),
}, []string{"function"})

func main() {
	secretName := os.Getenv("AWS_SECRET_NAME")
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region)},
	)
	if err != nil {
		log.Fatalf("Failed to create AWS session: %v", err)
	}
	fmt.Println("\nAWS Session created")

	svc := secretsmanager.New(sess)
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		log.Fatalf("Failed to retrieve secret: %v", err)
	}
	fmt.Println("\nSecret retrieved successfully")

	err = json.Unmarshal([]byte(*result.SecretString), &dbConfig)
	if err != nil {
		log.Fatalf("Failed to unmarshal secret: %v", err)
	}

	// Ensure the database exists
	if err := ensureDatabaseExists(dbConfig); err != nil {
		log.Fatalf("Failed to ensure database exists: %v", err)
	}

	// Ensure the table exists
	if err := ensureTableExists(dbConfig); err != nil {
		log.Fatalf("Failed to ensure table exists: %v", err)
	}
	http.Handle("/metrics", promhttp.Handler())
	http.HandleFunc("/backend", backendHandler)

	log.Println("Server is running on port 80")
	log.Fatal(http.ListenAndServe(":80", nil))
}

func ensureDatabaseExists(dbConfig DBConfig) error {
	// Open connection to the database server without specifying a database
	funcCount.WithLabelValues("ensureDatabaseExists").Inc()
	start := time.Now()
	defer func() {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.WithLabelValues("ensureDatabaseExists").Observe(float64(memStats.Alloc))
		cpuUtilization.WithLabelValues("ensureDatabaseExists").Observe(time.Since(start).Seconds())
	}()
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s sslmode=require",
		dbHost, dbPort, dbConfig.Username, dbConfig.Password)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		handleError(err, "ensureDatabaseExists", "database_connection_failed", start)
		return fmt.Errorf("failed to open database connection: %w", err)
	}
	defer db.Close()

	// Check if the database exists
	query := fmt.Sprintf("SELECT 1 FROM pg_database WHERE datname='%s'", dbName)
	var exists bool
	err = db.QueryRow(query).Scan(&exists)
	if err != nil && err != sql.ErrNoRows {
		return fmt.Errorf("failed to check if database exists: %w", err)
	}

	if !exists {
		// Create the database
		createDBQuery := fmt.Sprintf("CREATE DATABASE %s OWNER %s", dbName, dbConfig.Username)
		_, err := db.Exec(createDBQuery)
		if err != nil {
			handleError(err, "ensureDatabaseExists", "create_database_failed", start)
			return fmt.Errorf("failed to create database: %w", err)
		}
		log.Println("Database created successfully.")
	}

	return nil
}

func ensureTableExists(dbConfig DBConfig) error {
	// Open connection to the specific database
	funcCount.WithLabelValues("ensureTableExists").Inc()
	start := time.Now()
	defer func() {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.WithLabelValues("ensureTableExists").Observe(float64(memStats.Alloc))
		cpuUtilization.WithLabelValues("ensureTableExists").Observe(time.Since(start).Seconds())
	}()
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=require",
		dbHost, dbPort, dbConfig.Username, dbConfig.Password, dbName)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		handleError(err, "ensureTableExists", "database_connection_failed", start)
		return fmt.Errorf("failed to open database connection: %w", err)
	}
	defer db.Close()

	query := fmt.Sprintf("SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '%s')", tableName)
	var exists bool
	err = db.QueryRow(query).Scan(&exists)
	if err != nil {
		handleError(err, "ensureTableExists", "table_exist_check_failed", start)
		return fmt.Errorf("failed to check if table exists: %w", err)
	}

	if !exists {
		createTableQuery := fmt.Sprintf(`
            CREATE TABLE %s (
                id SERIAL PRIMARY KEY,
                data TEXT NOT NULL
            )
        `, tableName)
		_, err := db.Exec(createTableQuery)
		if err != nil {
			handleError(err, "ensureTableExists", "table_create_failed", start)
			return fmt.Errorf("failed to create table: %w", err)
		}
		log.Println("Table created successfully.")
	}
	return nil
}

func backendHandler(w http.ResponseWriter, r *http.Request) {
	funcCount.WithLabelValues("backendHandler").Inc()
	start := time.Now()
	defer func() {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.WithLabelValues("backendHandler").Observe(float64(memStats.Alloc))
		cpuUtilization.WithLabelValues("backendHandler").Observe(time.Since(start).Seconds())
	}()
	switch r.Method {
	case http.MethodPut:
		enterHandler(w, r)
	case http.MethodGet:
		getHandler(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)

	}
}

func enterHandler(w http.ResponseWriter, r *http.Request) {
	funcCount.WithLabelValues("enterHandler").Inc()
	start := time.Now()
	defer func() {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.WithLabelValues("enterHandler").Observe(float64(memStats.Alloc))
		cpuUtilization.WithLabelValues("enterHandler").Observe(time.Since(start).Seconds())
	}()
	var data Data

	// Log the incoming request details
	log.Printf("Received %s request from %s for URL: %s", r.Method, r.RemoteAddr, r.URL.String())

	// Read and parse the request body
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body", http.StatusBadRequest)
		log.Printf("Failed to read request body: %v", err)
		return
	}
	defer r.Body.Close()

	// Unmarshal JSON body into 'data' struct
	err = json.Unmarshal(body, &data)
	if err != nil {
		http.Error(w, "Failed to parse JSON", http.StatusBadRequest)
		log.Printf("Failed to parse JSON: %v", err)
		return
	}

	// Open database connection
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=require",
		dbHost, dbPort, dbConfig.Username, dbConfig.Password, dbName)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		http.Error(w, "Failed to open database connection", http.StatusInternalServerError)
		log.Printf("Failed to open database connection: %v", err)
		return
	}
	defer db.Close()

	// Insert data into database
	query := fmt.Sprintf("INSERT INTO %s (data) VALUES ($1) RETURNING id", tableName)
	var id int
	err = db.QueryRow(query, data.Data).Scan(&id)
	if err != nil {
		http.Error(w, "Failed to insert data into table", http.StatusInternalServerError)
		log.Printf("Failed to insert data into table: %v", err)
		return
	}

	// Log successful response and send response to client
	log.Printf("Inserted data with ID %d", id)
	w.WriteHeader(http.StatusCreated)
	fmt.Fprintf(w, "Your data was inserted with id :  %d", id)
}

func getHandler(w http.ResponseWriter, r *http.Request) {
	funcCount.WithLabelValues("getHandler").Inc()
	start := time.Now()
	defer func() {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)
		memoryUsage.WithLabelValues("getHandler").Observe(float64(memStats.Alloc))
		cpuUtilization.WithLabelValues("getHandler").Observe(time.Since(start).Seconds())
	}()
	// Log the incoming request details
	log.Printf("Received %s request from %s for URL: %s", r.Method, r.RemoteAddr, r.URL.String())

	// Set response headers
	w.Header().Set("Content-Type", "application/json")

	// Open database connection
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=require",
		dbHost, dbPort, dbConfig.Username, dbConfig.Password, dbName)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		http.Error(w, "Failed to open database connection", http.StatusInternalServerError)
		log.Printf("Failed to open database connection: %v", err)
		return
	}
	defer db.Close()

	// Query to fetch all data from the table
	query := fmt.Sprintf("SELECT id, data FROM %s", tableName)
	rows, err := db.Query(query)
	if err != nil {
		http.Error(w, "Failed to query data from table", http.StatusInternalServerError)
		log.Printf("Failed to query data from table: %v", err)
		return

	}
	defer rows.Close()

	// Slice to hold retrieved data
	var dataList []Data

	// Iterate over the rows returned by the query
	for rows.Next() {
		var data Data
		err := rows.Scan(&data.ID, &data.Data)
		if err != nil {
			http.Error(w, "Failed to scan row data", http.StatusInternalServerError)
			log.Printf("Failed to scan row data: %v", err)
			return
		}
		dataList = append(dataList, data)
	}
	if err := rows.Err(); err != nil {
		http.Error(w, "Error while iterating over rows", http.StatusInternalServerError)
		log.Printf("Error while iterating over rows: %v", err)
		return
	}

	// Serialize dataList to JSON
	response, err := json.Marshal(dataList)
	if err != nil {
		http.Error(w, "Failed to marshal JSON", http.StatusInternalServerError)
		log.Printf("Failed to marshal JSON: %v", err)
		return
	}

	// Write the JSON response
	w.WriteHeader(http.StatusOK)
	w.Write(response)

	// Log successful response
	log.Printf("Sent %d records as response", len(dataList))
}
