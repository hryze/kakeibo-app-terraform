resource "aws_cloudfront_origin_access_identity" "website" {
  comment = var.website_domain
}

resource "aws_cloudfront_distribution" "kakeibo_cloudfront_distribution" {
  aliases             = [var.website_domain]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.website_domain
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  tags                = merge(local.default_tags, tomap({ "Name" = "kakeibo-cloudfront-distribution" }))

  origin {
    domain_name = aws_s3_bucket.kakeibo_s3.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront_acm_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  depends_on = [
    aws_s3_bucket_public_access_block.kakeibo_s3,
    aws_s3_bucket_policy.kakeibo_s3_bucket_policy,
  ]
}
