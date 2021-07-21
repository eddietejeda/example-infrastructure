################################################################################
# Route 53
################################################################################

resource "aws_route53_zone" "zone" {
  name  = local.domain_name
  tags  = local.tags
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${local.public_url}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.load_balancer.dns_name]
}


resource "aws_route53_record" "wwww2" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${local.public_url2}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.load_balancer.dns_name]
}


resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}