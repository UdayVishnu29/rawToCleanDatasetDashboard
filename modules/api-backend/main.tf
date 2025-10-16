# --- 1. S3 Pre-signed URL Generator ---

# IAM Role for the presigned URL Lambda
resource "aws_iam_role" "presigned_url_role" {
  name               = "${var.project_name}-S3PresignedUrlRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy for the presigned URL Lambda
resource "aws_iam_role_policy" "presigned_url_policy" {
  name = "S3PutObjectPolicy"
  role = aws_iam_role.presigned_url_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "s3:PutObject",
      Resource = "arn:aws:s3:::${var.upload_bucket_name}/*"
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "presigned_url_basic_execution" {
  role       = aws_iam_role.presigned_url_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Zip the code for the presigned URL Lambda
data "archive_file" "presigned_url_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code/presigned-url-generator"
  output_path = "${path.module}/lambda-code/presigned-url-generator.zip"
}

# The presigned URL Lambda function
resource "aws_lambda_function" "presigned_url_lambda" {
  function_name    = "${var.project_name}-presigned-url-generator"
  role             = aws_iam_role.presigned_url_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.presigned_url_code.output_path
  source_code_hash = data.archive_file.presigned_url_code.output_base64sha26
  environment {
    variables = {
      UPLOAD_BUCKET_NAME = var.upload_bucket_name
    }
  }
}

# API Gateway for the presigned URL Lambda
resource "aws_apigatewayv2_api" "upload_api" {
  name          = "${var.project_name}-upload-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# Integration between the API and the Lambda
resource "aws_apigatewayv2_integration" "upload_api_lambda_integration" {
  api_id           = aws_apigatewayv2_api.upload_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.presigned_url_lambda.invoke_arn
}

# Route for the API
resource "aws_apigatewayv2_route" "upload_api_route" {
  api_id    = aws_apigatewayv2_api.upload_api.id
  route_key = "POST /get-upload-url"
  target    = "integrations/${aws_apigatewayv2_integration.upload_api_lambda_integration.id}"
}

# Lambda permission to allow API Gateway invocation
resource "aws_lambda_permission" "presigned_url_api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.upload_api.execution_arn}/*/*"
}



# IAM Role for the QuickSight Lambda
resource "aws_iam_role" "quicksight_url_role" {
  name               = "${var.project_name}-QuicksightEmbedUrlRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy for the QuickSight Lambda
resource "aws_iam_role_policy" "quicksight_url_policy" {
  name = "QuicksightEmbedUrlPolicy"
  role = aws_iam_role.quicksight_url_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "quicksight:GenerateEmbedUrlForRegisteredUser",
      Resource = [
        "arn:aws:quicksight:${var.aws_region_secondary}:${var.aws_account_id}:dashboard/${var.quicksight_dashboard_id}",
        var.quicksight_user_arn
      ]
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "quicksight_url_basic_execution" {
  role       = aws_iam_role.quicksight_url_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Zip the code for the QuickSight Lambda
data "archive_file" "quicksight_url_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code/quicksight-url-generator"
  output_path = "${path.module}/lambda-code/quicksight-url-generator.zip"
}

# The QuickSight URL Lambda function
resource "aws_lambda_function" "quicksight_url_lambda" {
  function_name    = "${var.project_name}-quicksight-url-generator"
  role             = aws_iam_role.quicksight_url_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.quicksight_url_code.output_path
  source_code_hash = data.archive_file.quicksight_url_code.output_base64sha26
  environment {
    variables = {
      DASHBOARD_ID     = var.quicksight_dashboard_id
      AWS_ACCOUNT_ID   = var.aws_account_id
      QUICKSIGHT_USER_ARN = var.quicksight_user_arn
    }
  }
}

# API Gateway for the QuickSight Lambda
resource "aws_apigatewayv2_api" "dashboard_api" {
  name          = "${var.project_name}-dashboard-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# Integration between the API and the Lambda
resource "aws_apigatewayv2_integration" "dashboard_api_lambda_integration" {
  api_id           = aws_apigatewayv2_api.dashboard_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.quicksight_url_lambda.invoke_arn
}

# Route for the API
resource "aws_apigatewayv2_route" "dashboard_api_route" {
  api_id    = aws_apigatewayv2_api.dashboard_api.id
  route_key = "GET /get-dashboard-url"
  target    = "integrations/${aws_apigatewayv2_integration.dashboard_api_lambda_integration.id}"
}

# Lambda permission to allow API Gateway invocation
resource "aws_lambda_permission" "quicksight_url_api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quicksight_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.dashboard_api.execution_arn}/*/*"
}