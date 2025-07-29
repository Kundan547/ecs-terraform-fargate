# modules/s3/main.tf
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects
    }

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    dynamic "transition" {
      for_each = var.transitions
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }
  }
}

# Bucket policy for specific use cases
data "aws_iam_policy_document" "bucket_policy" {
  count = length(var.allowed_principals) > 0 ? 1 : 0

  statement {
    sid       = "AllowSpecificPrincipals"
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.allowed_principals
    }
    actions   = var.allowed_actions
    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "main" {
  count  = length(var.allowed_principals) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

