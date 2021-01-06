module "github_actions_in_action_ecr" {
  source = "./ecr"
  name   = "github-actions-in-action"
  tags = {
    maintainer = "taufort"
    project    = "github-actions-in-action"
  }
}
