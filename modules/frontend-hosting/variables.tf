variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
}

variable "aws_region_primary" {
  description = "The AWS region for hosting the frontend."
  type        = string
}