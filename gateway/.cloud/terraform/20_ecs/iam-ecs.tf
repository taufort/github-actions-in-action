data "aws_iam_policy_document" "ecs_tasks_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "ecr_read_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "logs_write_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "ecs_gateway_role" {
  name               = "ecs-${var.tags["project"]}-${var.application}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "ecs_gateway_role_ecr_read_only_policy" {
  name   = "ecs-${var.tags["project"]}-${var.application}-ecr-read-only"
  policy = data.aws_iam_policy_document.ecr_read_policy.json
  role   = aws_iam_role.ecs_gateway_role.id
}

resource "aws_iam_role_policy" "ecs_gateway_role_logs_write_policy" {
  name   = "ecs-${var.tags["project"]}-${var.application}-logs-write-only"
  policy = data.aws_iam_policy_document.logs_write_policy.json
  role   = aws_iam_role.ecs_gateway_role.id
}