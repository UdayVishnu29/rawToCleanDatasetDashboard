variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
}

variable "aws_region_secondary" {
  description = "The AWS region for the backend APIs (e.g., us-east-1)."
  type        = string
}

variable "upload_bucket_name" {
  description = "The name of the S3 bucket where users will upload files."
  type        = string
}

variable "quicksight_dashboard_id" {
  description = "The ID of the permanent QuickSight dashboard."
  type        = string
}

variable "quicksight_user_arn" {
  description = "The ARN of the QuickSight viewer user."
  type        = string
}

variable "aws_account_id" {
  description = "Your 12-digit AWS Account ID."
  type        = string
}