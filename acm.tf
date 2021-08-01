################################################################################
# ACM
################################################################################

resource "aws_acm_certificate" "primary_cert" {
  domain_name       = "${aws_route53_record.primary.fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_acm_certificate" "secondary_cert" {
  domain_name       = "${aws_route53_record.secondary.fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}


resource "aws_acm_certificate_validation" "primary_certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.primary_cert.arn}"
  validation_record_fqdns = [for record in aws_route53_record.primary_cert_validation : record.fqdn]

  # Optional: Hook to add delay before aws_alb_listener_certificate.lb_listener_certificate
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "aws_acm_certificate_validation" "secondary_certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.secondary_cert.arn}"
  validation_record_fqdns = [for record in aws_route53_record.secondary_cert_validation : record.fqdn]

  # Optional: Hook to add delay before aws_lb_listener_certificate.lb_listener_certificate
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "aws_alb_listener_certificate" "lb_listener_certificate" {
  listener_arn    = aws_alb_listener.https_lb_listener.arn
  certificate_arn = aws_acm_certificate.primary_cert.arn
  
  depends_on = [
    aws_acm_certificate_validation.primary_certificate_validation
  ]

}