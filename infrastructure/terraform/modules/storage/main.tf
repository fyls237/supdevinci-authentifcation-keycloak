# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bucket"
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_id
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# S3 Bucket Logging (optional)
resource "aws_s3_bucket_logging" "bucket" {
  count = var.logging_bucket_name != "" ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.logging_bucket_name
  target_prefix = var.logging_prefix
}

# S3 Bucket Lifecycle Configuration (optional)
resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  count = var.enable_lifecycle_rules ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "expire-old-versions"
    status = var.enable_versioning ? "Enabled" : "Disabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  rule {
    id     = "delete-expired-delete-markers"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }
  }
}

# S3 Bucket Policy (optional)
resource "aws_s3_bucket_policy" "bucket" {
  count = var.bucket_policy != "" ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  policy = var.bucket_policy
}
