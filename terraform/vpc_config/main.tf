# This Terraform File is Responsible to create the entire VPC

#--------------------------------------------------
# Locals can be used anywhere in the Configurations
#--------------------------------------------------
locals {
  component="${var.app_name}-${var.env_name}"
  app_name=var.app_name
  env_name=var.env_name
  region=var.region
}


#------------------------
# VPC Creation
#------------------------
resource "aws_vpc" "dealer-service-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true  // It will provide a public Hostname to our EC2
  tags = {
    Name= local.component
  }
}

#----------------------------------------------------------------------------
# Below configuration is responsible to create the Public and Private Subnets.
#----------------------------------------------------------------------------

resource "aws_subnet" "public-subnet-1" {
  cidr_block = var.public_subnet_1_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}a"
  tags = {
    Name = "Dealer Service Public Subnet 1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block = var.public_subnet_2_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}b"
  tags = {
    Name = "Dealer Service Public Subnet 2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block = var.public_subnet_3_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}c"
  tags = {
    Name = "Dealer Service Public Subnet 3"
  }
}

resource "aws_subnet" "private-subnet-1" {
  cidr_block = var.private_subnet_1_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}a"
  tags = {
    Name = "Dealer Service Private Subnet 1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block = var.private_subnet_2_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}b"
  tags = {
    Name = "Dealer Service Private Subnet 2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block = var.private_subnet_3_cidr
  vpc_id     = aws_vpc.dealer-service-vpc.id
  availability_zone = "${local.region}c"
  tags = {
    Name = "Dealer Service Private Subnet 3"
  }
}

resource "aws_route_table" "dealer-service-public-route-table" {
  vpc_id = aws_vpc.dealer-service-vpc.id
  tags = {
    Name = "Dealer Service Public Route Table"
  }
}

resource "aws_route_table" "dealer-service-private-route-table" {
  vpc_id = aws_vpc.dealer-service-vpc.id
  tags = {
    Name = "Dealer Service Private Route Table"
  }
}

#--------------------------------------------------------------------------------------------------
# Below configuration is responsible to Associate Public Route Tables with respected Public Subnets.
#--------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = aws_route_table.dealer-service-public-route-table.id
  subnet_id = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  route_table_id = aws_route_table.dealer-service-public-route-table.id
  subnet_id = aws_subnet.public-subnet-2.id
}

resource "aws_route_table_association" "public-subnet-3-association" {
  route_table_id = aws_route_table.dealer-service-public-route-table.id
  subnet_id = aws_subnet.public-subnet-3.id
}

resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id = aws_route_table.dealer-service-private-route-table.id
  subnet_id = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  route_table_id = aws_route_table.dealer-service-private-route-table.id
  subnet_id = aws_subnet.private-subnet-2.id
}

resource "aws_route_table_association" "private-subnet-3-association" {
  route_table_id = aws_route_table.dealer-service-private-route-table.id
  subnet_id = aws_subnet.private-subnet-3.id
}
#--------------------------------------------------------------------------------------------------
# We want our private Subnet Resource to access internet , but do not want to allow traffic from
# the outside world. We would create a NAT Gateway for that , but before that we will be creating
# this Elastic IP.
#--------------------------------------------------------------------------------------------------

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "${local.component}-eip"
  }
}

#------------------------------------------------------------
# Below configuration is responsible to Create a NAT Gateway.
#------------------------------------------------------------

resource "aws_nat_gateway" "Dealer-Service_NAT_Gateway" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id = aws_subnet.public-subnet-1.id
  tags = {
    Name = "${local.component}-NAT-Gateway"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw]  // Creation of NAT GW is depends on the EIP Creation.
}

#-----------------------------------------------------------------
# We need to associate the NAT GW with the Private Route Table now.
# Below configuration is responsible to this association.
#-----------------------------------------------------------------

resource "aws_route" "Dealer-Service-NAT-Gateway-Route" {
  route_table_id          = aws_route_table.dealer-service-private-route-table.id
  nat_gateway_id          = aws_nat_gateway.Dealer-Service_NAT_Gateway.id
  destination_cidr_block  = "0.0.0.0/0" // This will allow access internet traffic from our instances to the outside world but not vise versa.
}

#----------------------------------------------------------------------------
# We need to Create an Internet Gateway , so that outside traffic be entertain,
# and Public resources can be accessed publicly
#-----------------------------------------------------------------------------

resource "aws_internet_gateway" "Dealer-Service-Internet-Gateway" {
  vpc_id = aws_vpc.dealer-service-vpc.id
  tags = {
    Name = "${local.component}-Internet-Gateway"
  }
}

#----------------------------------------------------------------------------
# Once IGW gets created , will need to map that to Public Route Table.
#-----------------------------------------------------------------------------

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.dealer-service-public-route-table.id
  gateway_id             = aws_internet_gateway.Dealer-Service-Internet-Gateway.id
  destination_cidr_block = "0.0.0.0/0"  // Allow our public resources to connect to internet properly
}