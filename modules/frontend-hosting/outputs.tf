output "website_endpoint" {
  description = "The public URL for the static website."
  value       = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}