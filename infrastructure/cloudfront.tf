provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_cloudfront_cache_policy" "website_cloudfront" {
  name        = "Managed-CachingOptimized"
  comment     = "Policy with caching enabled. Supports Gzip and Brotli compression."
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_acm_certificate" "website_cert" {
  provider          = aws.us_east_1
  domain_name       = "tzeyang.ng"
  validation_method = "DNS"
}

resource "aws_route53_record" "website_cert" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.tzeyang_ng.zone_id
  records = [each.value.record]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "example" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_cert : record.fqdn]
}

resource "aws_cloudfront_distribution" "website_cloudfront" {

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["tzeyang.ng"]

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    origin_id           = aws_s3_bucket.website.bucket_regional_domain_name
    domain_name         = aws_s3_bucket_website_configuration.website.website_endpoint

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    cache_policy_id = aws_cloudfront_cache_policy.website_cloudfront.id

    target_origin_id = aws_s3_bucket.website.bucket_regional_domain_name
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.website_cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  price_class = "PriceClass_200"

}