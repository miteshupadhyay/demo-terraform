# ---------------------------------------------------------------------------------
# This File will Store the variable that are common for all the Environments.
# ---------------------------------------------------------------------------------

variable "region" {
  default = "ap-south-1"
  description = "AWS Region that we wants to have our infrastructure in"
  type = string
  validation {
    condition = length(var.region) > 5 && var.region == "ap-south-1"
    error_message = "Region Value should not be other then ap-south-1."
  }
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "CIDR Block of our Production VPC"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for the Public Subnet 1"
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for the Public Subnet 2"
  default = "10.0.2.0/24"
}

variable "public_subnet_3_cidr" {
  description = "CIDR for the Public Subnet 3"
  default = "10.0.3.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for the Private Subnet 1"
  default = "10.0.4.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for the Private Subnet 2"
  default = "10.0.5.0/24"
}

variable "private_subnet_3_cidr" {
  description = "CIDR for the Private Subnet 3"
  default = "10.0.6.0/24"
}

variable "app_name" {
  default = "dealer-service"
  type = string
  description = "Name of the Application"
}

variable "env_name" {
  description = "Environment where this resources will get deployed"
  type = string
}
