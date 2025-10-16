variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
}

variable "aws_region_secondary" {
  description = "The AWS region for the data pipeline."
  type        = string
}