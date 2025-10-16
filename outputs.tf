output "website_url" {
  description = "The public URL for the frontend website."
  value       = module.frontend_hosting.website_endpoint
}

output "upload_api_url" {
  description = "The API endpoint for generating a secure S3 upload URL."
  value       = module.api_backend.upload_api_endpoint
}

output "dashboard_api_url" {
  description = "The API endpoint for generating the secure QuickSight dashboard URL."
  value       = module.api_backend.dashboard_api_endpoint
}