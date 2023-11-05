resource "aws_route53_zone" "tzeyang_ng" {
  name = "tzeyang.ng"
}

resource "aws_route53_record" "tzeyang_a" {
  zone_id = aws_route53_zone.tzeyang_ng.zone_id
  name    = "tzeyang.ng"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.website_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "tzeyang_ns" {
  zone_id = aws_route53_zone.tzeyang_ng.zone_id
  name    = "tzeyang.ng"
  type    = "NS"
  ttl     = 172800
  records = [
    "ns-1454.awsdns-53.org.",
    "ns-757.awsdns-30.net.",
    "ns-1983.awsdns-55.co.uk.",
    "ns-325.awsdns-40.com."
  ]
}

resource "aws_route53_record" "tzeyang_soa" {
  zone_id = aws_route53_zone.tzeyang_ng.zone_id
  name    = "tzeyang.ng"
  type    = "SOA"
  ttl     = 900
  records = [
    "ns-1454.awsdns-53.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}