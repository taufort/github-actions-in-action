resource "aws_ecs_cluster" "github_actions_in_action_fargate_cluster" {
  name = var.tags["project"]
  capacity_providers = [
    "FARGATE"
  ]
  tags = var.tags
}
