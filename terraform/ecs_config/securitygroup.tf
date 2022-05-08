#--------------------------------------------------------
# This File contains the Security Groups needed
#--------------------------------------------------------

#--------------------------------------------------------------------------
# Below Security is responsible to allow ALB Accessible from Public Network
# that will route to ECS Cluster
#--------------------------------------------------------------------------
resource "aws_security_group" "ecs_alb_security_group" {
  name = "${var.ecs_cluster_name}-ALB-SG"
  description = "Security Group for ALB to traffic for ECS Cluster"
  vpc_id = data.terraform_remote_state.remote_state_vpc_output.outputs.vpc_id

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [var.internet_cidr_blocks]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [var.internet_cidr_blocks]
  }
}