resource "aws_lb_listener_rule" "gateway_listener_rule" {
  listener_arn = data.terraform_remote_state.base_infrastructure.outputs.main_alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.base_infrastructure.outputs.main_alb_target_group_arn
  }

  condition {
    path_pattern {
      values = [
        "/hello"
      ]
    }
  }
}
