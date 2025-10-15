# VPC creation  
resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "${var.project_name}"
    }
}

# Public Subnet creation
resource "aws_subnet" "public_subnets"{
    count = length(var.public_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.public_subnet_cidr, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {
        Name = "Public Subnet ${count.index + 1}"
    }
}

# Private Subnet creation
resource "aws_subnet" "private_subnets"{
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.private_subnet_cidr, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {
        Name = "Private Subnet ${count.index + 1}"
    }
}

# Internet Gateway creation
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}_igw"
    }
}

# Elastic IP for the NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}_P"
  }
}

# Nat gateway for Private subnets
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public subnet route table creation
resource "aws_route_table" "public_route_table"{
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.project_name} Public Route table"
    }
}

# Private subnet route table creation
resource "aws_route_table" "private_route_table"{
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name} Private Route table"
    }
}

# Associate public subnet to Public route table
resource "aws_route_table_association" "public_subnet_association"{
    count = length(var.public_subnet_cidr)
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
    route_table_id = aws_route_table.public_route_table.id
}

# Associate private subnet to Private route table
resource "aws_route_table_association" "private_subnet_association"{
    count = length(var.private_subnet_cidr)
    subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
    route_table_id = aws_route_table.private_route_table.id
}

# Associate Nat to Private route table
resource "aws_route" "private_nat_route"{
    route_table_id = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id

    depends_on = [aws_nat_gateway.ngw]
}
