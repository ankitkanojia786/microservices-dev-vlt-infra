# Use existing VPC (passed as variable)
# VPC is referenced via vpc_id variable

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-public-subnet-${count.index + 1}"
    "ohi:subnet-type" = "public"
  })
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-private-subnet-${count.index + 1}"
    "ohi:subnet-type" = "private"
  })
}

# Get available AZs
data "aws_availability_zones" "available" {}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-igw"
  })
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-nat-eip"
  })
}

# Create NAT Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-nat-gateway"
  })
  
  depends_on = [aws_internet_gateway.this]
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-public-rt"
  })
}

# Create private route table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-private-rt"
  })
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}