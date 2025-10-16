# S3 bucket for raw data uploads
resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "${var.project_name}-raw-data-${random_string.bucket_suffix.result}"
}

# S3 bucket for Athena query results
resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = "${var.project_name}-athena-results-${random_string.bucket_suffix.result}"
}

# IAM Role for the Glue Crawler
resource "aws_iam_role" "glue_crawler_role" {
  name               = "${var.project_name}-GlueCrawlerRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

# AWS managed policy for Glue
resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Add a policy to allow reading from your S3 bucket
resource "aws_iam_role_policy" "glue_s3_read_policy" {
  name = "GlueS3ReadAccessPolicy"
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = [
        aws_s3_bucket.raw_data_bucket.arn,
        "${aws_s3_bucket.raw_data_bucket.arn}/*"
      ]
    }]
  })
}

# AWS Glue Catalog Database
resource "aws_glue_catalog_database" "sales_database" {
  name = "${var.project_name}_sales_db"
}

# AWS Glue Crawler
resource "aws_glue_crawler" "sales_crawler" {
  name          = "${var.project_name}-sales-crawler"
  database_name = aws_glue_catalog_database.sales_database.name
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.raw_data_bucket.id}"
  }
}

# Helper to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}