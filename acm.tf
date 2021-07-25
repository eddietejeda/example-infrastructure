################################################################################
# ACM
################################################################################

resource "aws_acm_certificate" "cert" {
  domain_name       = "${aws_route53_record.www.fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  tags = local.tags
}

resource "aws_lb_listener_certificate" "lb_listener_certificate" {
  depends_on = [aws_acm_certificate_validation.certificate_validation]
  listener_arn    = aws_lb_listener.https_lb_listener.arn
  certificate_arn = aws_acm_certificate.cert.arn
}


resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # Optional: Hook to add delay before aws_lb_listener_certificate.lb_listener_certificate
  # provisioner "local-exec" {
  #   command = "sleep 10"
  # }
}