provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# 1. The S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "sp-02022026-state-bucket-${data.aws_caller_identity.current.account_id}"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce encryption for compliance
resource "aws_s3_bucket_server_side_encryption_configuration" "state_crypto" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 1. IAM Role for GitHub to Assume
resource "aws_iam_role" "github_role" {
  name = "GitHub-Governance-Hero-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          # Use your existing Provider ARN here
          Federated = "arn:aws:iam::319310747432:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:sprakriy/aws-governance-automation:*"
          }
        }
      }
    ]
  })
}

# 2. Policy for the Lambda & EventBridge management
# (Hero tip: Narrow this down to EC2/Lambda/EventBridge permissions)
resource "aws_iam_role_policy" "github_policy" {
  name = "GitHubActionsPolicy"
  role = aws_iam_role.github_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*", "ec2:CreateSnapshot", "lambda:*", 
          "events:*", "iam:PassRole", "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}
# Add this to your existing bootstrap file to give GitHub the "Admin" muscle it needs
resource "aws_iam_role_policy_attachment" "github_iam_admin" {
  role       = aws_iam_role.github_role.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" 
}