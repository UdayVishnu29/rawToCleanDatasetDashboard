variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
  default     = "data-pipeline-app"
}

variable "aws_region_primary" {
  description = "The primary AWS region for hosting the frontend (e.g., ap-south-1)."
  type        = string
  default     = "ap-south-1"
}

variable "aws_region_secondary" {
  description = "The secondary AWS region for the backend logic (e.g., us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "quicksight_dashboard_id" {
  description = "The ID of the permanent QuickSight dashboard."
  type        = string
  sensitive   = true
}

variable "quicksight_user_arn" {
  description = "The ARN of the QuickSight viewer user (e.g., arn:aws:quicksight:us-east-1:ACCOUNT_ID:user/default/email@domain.com)."
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "Your 12-digit AWS Account ID."
  type        = string
  sensitive   = true
}