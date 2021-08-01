################################################################################
# Route 53
################################################################################

resource "aws_route53_zone" "primary" {
  name  = var.primary_domain
  tags  = local.tags
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "${local.primary_url}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.load_balancer.dns_name]

}

resource "aws_route53_zone" "secondary" {
  name  = var.secondary_domain
  tags  = local.tags
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.secondary.zone_id
  name    = "${local.secondary_url}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.load_balancer.dns_name]

}

resource "aws_route53_record" "primary_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.primary_cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.primary.zone_id

}

resource "aws_route53_record" "secondary_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.secondary_cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.secondary.zone_id

}