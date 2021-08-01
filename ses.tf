################################################################################
# SES
################################################################################

resource "aws_ses_domain_mail_from" "mailer" {
  domain           = aws_ses_domain_identity.mailer.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.mailer.domain}"
}

# Mailer SES Domain Identity
resource "aws_ses_domain_identity" "mailer" {
  domain = var.primary_domain
}

# Mailer Route53 MX record
resource "aws_route53_record" "mailer_ses_domain_mail_from_mx" {
  zone_id = aws_route53_zone.primary.id
  name    = aws_ses_domain_mail_from.mailer.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.mailer` is created
}

# Mailer Route53 TXT record for SPF
resource "aws_route53_record" "mailer_ses_domain_mail_from_txt" {
  zone_id = aws_route53_zone.primary.id
  name    = aws_ses_domain_mail_from.mailer.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}