# S3 bucket to host the static website
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project_name}-frontend-hosting-${random_string.bucket_suffix.result}"
}

# Configure the bucket for public website hosting
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Unblock public access for the bucket
resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Apply a bucket policy to allow public read access
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend_public_access]
}

# Helper to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}