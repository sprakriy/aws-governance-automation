terraform {
  backend "s3" {
    bucket         = "sp-02022026-state-bucket-319310747432"
    key            = "governance/prod.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # No DynamoDB needed for 2026 consistency!
  }
}