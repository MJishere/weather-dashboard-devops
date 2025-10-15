# ------------------------------------------------
# S3 bucket for Terraform state (unique)
# ------------------------------------------------
resource "aws_s3_bucket" "tf_backend" {
  bucket        = "weather-dashboard-manoj-tf"
  force_destroy = true

  tags = {
    Name        = "terraform-state"
    Environment = "dev"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "tf_backend_block" {
  bucket                  = aws_s3_bucket.tf_backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------
# DynamoDB table for state locking (unique)
# ------------------------------------------------
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-locks-weather-dashboard-manoj"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock-table"
    Environment = "dev"
  }
}
