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

variable "app_name" {
  default = "dealer-service"
  type = string
  description = "Name of the Application"
}

variable "env_name" {
  description = "Environment where this resources will get deployed"
  type = string
}

variable "remote_state_bucket" {
  default = "dealer-service-terraform-remote-state"
  description = "Bucket Where from Remote Configurations needs to be read"
}

variable "remote_state_key" {
  default = "dealer-service-dev"
  description = "Key for which Infrastructure needs to be read"
}

variable "ecs_cluster_name" {
  default = "Dealer-Service-Cluster"
  description = "Name of the ECS Cluster"
}

variable "internet_cidr_blocks" {
  default = "0.0.0.0/0"
}

variable "ecs_domain_name" {
  default = "cloudtechlearn.com"
}