# This Terraform File is Responsible to create the Task Definition Resources.

#-----------------------------------------------------------------------
# Below configuration is to read the values from remote Infrastructure
# State File from S3 Bucket of ECS Output defined
#-----------------------------------------------------------------------

data "terraform_remote_state" "remote_state_vpc_output" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
  }
}

#---------------------------------------------------------------------------------------
# In order to Read task_definition file as a JSON file and to pass the variables that we
# created there , so that Task Definition can be resolved before it can be pushed to AWS
#---------------------------------------------------------------------------------------

data "template_file" "task_definition_json" {
  template = file("task_definition.json")
  vars = {
    task_definition_name = var.ecs_service_name
    application_name =  var.app_name
    env=var.app_name
    docker_image_url=var.docker_image_url
    region=var.region
  }
}

#----------------------------------------------------------------------------------
# Since we have our template file being read by terraform from task definition.json
# is has been read. Now create actual task definition by using above definition template.
#----------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "dealerserviceapp-task-definition" {
  container_definitions    = data.template_file.task_definition_json.rendered
  family                   = var.ecs_service_name
  cpu                      = 512
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_iam_role.arn
  task_role_arn            = aws_iam_role.fargate_iam_role.arn
}

#---------------------------------------------
# Create Task Execution Role for Fargate Task
#---------------------------------------------

resource "aws_iam_role" "fargate_iam_role" {
  name               = "${var.ecs_service_name}${"-IAM-Role"}"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Effect": "Allow",
   "Principal": {
     "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
   },
   "Action": "sts:AssumeRole"
  }
  ]
 }
EOF
}

#-----------------------------------------------
# Create Task Execution Role for IAM Role Policy
#-----------------------------------------------

resource "aws_iam_role_policy" "fargate_iam_role_policy" {
  name   = "${var.ecs_service_name}${"-IAM-Role-Policy"}"
  role   = aws_iam_role.fargate_iam_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#--------------------------------------------------
# Create Security Group for our App on Fargate
#--------------------------------------------------

resource "aws_security_group" "app_security_group" {
  name        = "${var.ecs_service_name}-SG"
  description = "Security group for spring boot app Dealer Service   to communicate in and out"
  vpc_id      = data.terraform_remote_state.remote_state_vpc_output.outputs.vpc_id

  ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8080
    cidr_blocks = [data.terraform_remote_state.remote_state_vpc_output.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}
#-------------------------------------------------------
# Let's Create ALB Target Group and we can register our
# ECS Fargate task, that we can use with our ALB
#-------------------------------------------------------

resource "aws_alb_target_group" "ecs_app_target_group" {
  name        = "${var.ecs_service_name}-TG"
  port        =  8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.remote_state_vpc_output.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/demo/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "60"
    timeout             = "30"
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

#----------------------
# Create an ECS Service
#----------------------

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  task_definition = aws_ecs_task_definition.dealerserviceapp-task-definition.arn
  desired_count   = 1
  cluster         = data.terraform_remote_state.remote_state_vpc_output.outputs.ecs_cluster_name.name
  launch_type     = "FARGATE"

  network_configuration {
    # subnets           = [data.terraform_remote_state.platform.outputs.ecs_public_subnets]
    subnets          = data.terraform_remote_state.remote_state_vpc_output.outputs.ecs_public_subnets
    security_groups  = [aws_security_group.app_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.ecs_service_name
    container_port   = 8080
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }
}

#--------------------------------------------------------------------------------------
# Now let's create our Load Balancer Listener Rule ,so that our we can attach our target
# Group to the Load Balancer and to the Actual Listener Rule
#---------------------------------------------------------------------------------------
resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = data.terraform_remote_state.remote_state_vpc_output.outputs.ecs_alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

  condition {
    host_header {
      values = ["${lower(var.ecs_service_name)}.${data.terraform_remote_state.remote_state_vpc_output.outputs.ecs_domain_name}"]
    }
  }
}
#---------------------------------------------------------
# Now let's create the Log Group for the application logs
#---------------------------------------------------------

resource "aws_cloudwatch_log_group" "dealerserviceapp_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}