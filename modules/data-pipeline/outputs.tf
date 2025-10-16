output "raw_data_bucket_name" {
  description = "The name of the S3 bucket for raw data uploads."
  value       = aws_s3_bucket.raw_data_bucket.id
}

output "athena_results_bucket_name" {
  description = "The name of the S3 bucket for Athena query results."
  value       = aws_s3_bucket.athena_results_bucket.id
}