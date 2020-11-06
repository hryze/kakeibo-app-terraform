data "aws_route53_zone" "website_zone" {
  name         = var.root_domain
  private_zone = false
  tags         = merge(local.default_tags, map("Name", var.root_domain))
}

resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.website_zone.zone_id
  name    = var.website_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.kakeibo_cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.kakeibo_cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
