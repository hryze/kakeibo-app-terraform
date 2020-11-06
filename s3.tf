resource "aws_s3_bucket" "kakeibo_s3" {
  bucket = var.s3_bucketname
  acl    = "private"
  tags   = merge(local.default_tags, map("Name", "kakeibo-s3"))

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  lifecycle_rule {
    id      = "clean-up"
    enabled = true

    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kakeibo_s3" {
  bucket                  = aws_s3_bucket.kakeibo_s3.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket_policy.kakeibo_s3_bucket_policy]
}
