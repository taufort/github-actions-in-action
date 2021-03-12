data "aws_iam_policy_document" "assume_role_vpc_logs_service" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "aws_flow_logs_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "aws_flow_logs_policy" {
  name        = "${var.project}-aws-flow-logs-policy"
  description = "Allows the VPC Flow log service to push to CloudWatch"
  policy      = data.aws_iam_policy_document.aws_flow_logs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "aws_flow_logs_attach" {
  role       = aws_iam_role.aws_flow_logs_role.name
  policy_arn = aws_iam_policy.aws_flow_logs_policy.arn
}

resource "aws_iam_role" "aws_flow_logs_role" {
  name               = "${var.project}-aws-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_vpc_logs_service.json

  tags = var.extra_tags
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_cloudwatch_log_group" {
  name              = "${var.project}-vpc-flow-logs-deny"
  retention_in_days = 7
}

resource "aws_flow_log" "vpc_reject_flow_log" {
  iam_role_arn    = aws_iam_role.aws_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_cloudwatch_log_group.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id
}
