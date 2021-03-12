data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = "github-actions-in-action"
    key    = "terraform/gateway/10_ecr/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "aws_ecs_cluster" "github_actions_in_action_fargate_cluster" {
  cluster_name = var.tags["project"]
}

resource "aws_ecs_task_definition" "gateway_task_definition" {
  family = "${var.tags["project"]}-${var.application}"

  container_definitions = templatefile("${path.module}/${var.application}.json", {
    project     = var.tags["project"]
    application = var.application
    ecr_url     = data.terraform_remote_state.ecr.outputs.gateway_ecr_repository_url
  })

  requires_compatibilities = [
    "FARGATE"
  ]
  network_mode = "awsvpc"

  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.ecs_gateway_role.arn
  execution_role_arn = aws_iam_role.ecs_gateway_role.arn

  tags = var.tags
}

data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"

  config = {
    bucket = "github-actions-in-action"
    key    = "terraform/base-infrastructure/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_ecs_service" "gateway_service" {
  name            = "${var.tags["project"]}-${var.application}"
  cluster         = data.aws_ecs_cluster.github_actions_in_action_fargate_cluster.arn
  task_definition = aws_ecs_task_definition.gateway_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.terraform_remote_state.base_infrastructure.outputs.main_vpc_private_subnets_ids
    security_groups = [
      aws_security_group.gateway_service_security_group.id
    ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.base_infrastructure.outputs.main_alb_target_group_arn
    container_name   = "${var.tags["project"]}-${var.application}"
    container_port   = 8080
  }
}

resource "aws_security_group" "gateway_service_security_group" {
  name        = "${var.tags["project"]}-gateway-service"
  description = "${var.tags["project"]} Gateway service"

  vpc_id = data.terraform_remote_state.base_infrastructure.outputs.main_vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    description = "Allow traffic on gateway port"
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    description = "Allow HTTPS towards internet (for docker pull for instance)"
  }

  tags = merge(
    { Name = "${var.tags["project"]}:gateway-service" },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "gateway_log_group" {
  name              = "/ecs/${var.tags["project"]}/${var.application}"
  retention_in_days = 7
  tags              = var.tags
}
