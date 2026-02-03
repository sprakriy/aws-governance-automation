# 1. Automatically zip the Python code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = "${path.module}/src/lambda_function.zip"
}

# 2. The IAM Role for the Lambda (Least Privilege)
resource "aws_iam_role" "lambda_exec" {
  name = "ResourceAuditorLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 3. Policy to allow Lambda to Snapshot and Describe EBS
resource "aws_iam_role_policy" "lambda_policy" {
  name = "ResourceAuditorPolicy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 4. The Lambda Function itself
resource "aws_lambda_function" "auditor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ebs-idle-resource-auditor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler" # Maps to index.py -> def handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 60

  tags = {
    Project = "Governance-Automation"
  }
}