resource "aws_acm_certificate" "cloudfront_acm_cert" {
  domain_name               = var.root_domain
  subject_alternative_names = [format("*.%s", var.root_domain)]
  validation_method         = "DNS"
  provider                  = aws.virginia
  tags                      = merge(local.default_tags, tomap({ "Name" = "cloudfront-acm-certificate" }))
}

resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_acm_cert.domain_validation_options : dvo.domain_name => {
      zone_id = data.aws_route53_zone.website_zone.zone_id
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = each.value.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60

  depends_on = [aws_acm_certificate.cloudfront_acm_cert]
}

resource "aws_acm_certificate_validation" "cloudfront_acm_cert" {
  certificate_arn         = aws_acm_certificate.cloudfront_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_validation : record.fqdn]
  provider                = aws.virginia
}

resource "aws_acm_certificate" "alb_ingress_acm_cert" {
  domain_name               = var.root_domain
  subject_alternative_names = [format("*.%s", var.root_domain)]
  validation_method         = "DNS"
  tags                      = merge(local.default_tags, tomap({ "Name" = "alb-ingress-acm-certificate" }))

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "alb_ingress_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_ingress_acm_cert.domain_validation_options : dvo.domain_name => {
      zone_id = data.aws_route53_zone.website_zone.zone_id
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = each.value.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60

  depends_on = [aws_acm_certificate.alb_ingress_acm_cert]
}

resource "aws_acm_certificate_validation" "alb_ingress_acm_cert" {
  certificate_arn         = aws_acm_certificate.alb_ingress_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_ingress_cert_validation : record.fqdn]
}
