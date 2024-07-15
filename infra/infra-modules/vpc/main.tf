resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.name_prefix}-vpc"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-igw"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "${var.name_prefix}-nat-gateway"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-eip"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.name_prefix}-public-rt"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${var.name_prefix}-private-rt"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

