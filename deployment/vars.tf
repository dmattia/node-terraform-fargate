variable "aws_region" {
  default     = "eu-west-1"
  description = "Which region should the resources be deployed into?"
}

variable "ecr_name" {
  default = "ecr_example_app"
}

variable "ecs_family" {
  default = "ecs_family_example_app"
}

variable "datadog_api_key" {
  description = "API key for datadog, should be different for each environment"
}