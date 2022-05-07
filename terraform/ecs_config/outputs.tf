#--------------------------------------------------------------------------
# Below entire configuration is for the variables that we want to have
# as output and this can be referenced as a input to other configuration.
#--------------------------------------------------------------------------

output "vpc_id" {
  value = data.terraform_remote_state.dealer-service-dev.outputs.vpc_id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.dealer-service-dev.outputs.vpc_cidr_block
}

output "ecs_alb_listener_arn" {
  value = aws_alb_listener.ecs_alb_https_listener.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.dealer-service-cluster.name
}

output "ecs_cluster_role_name" {
  value = aws_iam_role.ecs_cluster_role.name
}

output "ecs_cluster_role_arn" {
  value = aws_iam_role.ecs_cluster_role.arn
}

output "ecs_domain_name" {
  value = var.ecs_domain_name
}

output "ecs_public_subnets" {
  value = data.terraform_remote_state.dealer-service-dev.outputs.public_subnets
}

output "ecs_private_subnets" {
  value = data.terraform_remote_state.dealer-service-dev.outputs.private_subnets
}