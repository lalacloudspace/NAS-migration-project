# --------------------------
# VPC
# --------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr #the VPC CIDR block is passed from variable
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# --------------------------
# Internet Gateway (Public Internet Access)
# --------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id # Attach to the VPC, you have the <resource type>.<resource name>.<attribute>

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# --------------------------
# Public Subnets
# --------------------------
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs) # Create as many subnets as there are CIDRs provided

  vpc_id            = aws_vpc.main_vpc.id # This is the samething a did in the internet gateway above
  cidr_block        = var.public_subnet_cidrs[count.index] # I use count.index to make it dynamic instead of hardcoding an index EX: [0], [1], etc.
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  } #This will name the subnets like: VPCNAME-public-1, VPCNAME-public-2, automatically I don't have to hardcode it
}

# --------------------------
# Private Subnets and repeat for private subnets
# --------------------------
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

# --------------------------
# NAT Gateway (for Private Subnets to Access Internet)
# --------------------------
# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw] # Ensure IGW exists before EIP

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  depends_on = [aws_eip.nat_eip] # Ensure EIP is ready before NAT

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}


# --------------------------
# Route Table for Public Subnets
# --------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # The destination is from anywhere in the internet.
    gateway_id = aws_internet_gateway.igw.id # The target is the internet gateway created above.
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.public_subnet_cidrs) # Associate all public subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id # Get the ID of each public subnet created above
  route_table_id = aws_route_table.public_rt.id # Associate to the public route table created above
}

# --------------------------
# Route Table for Private Subnets
# --------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # The target is the NAT gateway created above
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id # Get the ID of each private subnet created above
  route_table_id = aws_route_table.private_rt.id # Associate to the private route table created above
}


# # create vpc
# resource "aws_vpc" "vpc" {
#   cidr_block              = 
#   instance_tenancy        = 
#   enable_dns_hostnames    = true

#   tags      = {
#     Name    = "${}-vpc"
#   }
# }

# # create internet gateway and attach it to vpc
# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id    = 

#   tags      = {
#     Name    = "${}-igw"
#   }
# }

# # use data source to get all avalablility zones in region
# data "aws_availability_zones" "available_zones" {}

# # create public subnet az1
# resource "aws_subnet" "public_subnet_az1" {
#   vpc_id                  = 
#   cidr_block              = 
#   availability_zone       = 
#   map_public_ip_on_launch = 

#   tags      = {
#     Name    = 
#   }
# }

# # create public subnet az2
# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id                  = 
#   cidr_block              = 
#   availability_zone       = 
#   map_public_ip_on_launch = 

#   tags      = {
#     Name    = 
#   }
# }

# # create route table and add public route
# resource "aws_route_table" "public_route_table" {
#   vpc_id       = 

#   route {
#     cidr_block = 
#     gateway_id = 
#   }

#   tags       = {
#     Name     = 
#   }
# }

# # associate public subnet az1 to "public route table"
# resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
#   subnet_id           = 
#   route_table_id      = 
# }

# # associate public subnet az2 to "public route table"
# resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
#   subnet_id           = 
#   route_table_id      = 
# }

# # create private app subnet az1
# resource "aws_subnet" "private_app_subnet_az1" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private app subnet az2
# resource "aws_subnet" "private_app_subnet_az2" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private data subnet az1
# resource "aws_subnet" "private_data_subnet_az1" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private data subnet az2
# resource "aws_subnet" "private_data_subnet_az2" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }