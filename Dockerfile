FROM golang:1.22 as build
WORKDIR /go/src/app
COPY main.go .
RUN go mod init mymodule
RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o application .
RUN chmod 755 application

# FROM gcr.io/distroless/static-debian11
FROM nginx
WORKDIR /var/task
COPY --from=build --chmod=755 /go/src/app/application .
CMD ["./application"]
