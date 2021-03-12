variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
