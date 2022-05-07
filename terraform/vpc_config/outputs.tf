#--------------------------------------------------------------------------
# Below entire configuration is for the variables that we want to have
# as output and this can be referenced as a input to other configuration.
#--------------------------------------------------------------------------

output "vpc_id" {
  value = aws_vpc.dealer-service-vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.dealer-service-vpc.cidr_block
}

output "public_Subnet_1_cidr_id" {
  value = aws_subnet.public-subnet-1.id
}

output "public_Subnet_2_cidr_id" {
  value = aws_subnet.public-subnet-2.id
}

output "public_Subnet_3_cidr_id" {
  value = aws_subnet.public-subnet-3.id
}

output "private_Subnet_1_cidr_id" {
  value = aws_subnet.private-subnet-1.id
}

output "private_Subnet_2_cidr_id" {
  value = aws_subnet.private-subnet-2.id
}

output "private_Subnet_3_cidr_id" {
  value = aws_subnet.private-subnet-3.id
}

output "private_subnets" {
  value = tolist([aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id])
}

output "public_subnets" {
  value = tolist([aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.public-subnet-3.id])
}