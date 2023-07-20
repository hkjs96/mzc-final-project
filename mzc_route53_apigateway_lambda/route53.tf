resource "aws_acm_certificate" "api" {
  # cloudfront 같은 것을 이용하려면 버지니아 북부에 인증서를 발급받아야한다.
  provider = aws.virginia

  # domain_name       = "api.goorm.shop"
  domain_name       = "*.goorm.shop"
  validation_method = "DNS"

  tags = {
    Environment = "prod"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

data "aws_route53_zone" "public" {
  name         = "goorm.shop"
  private_zone = false
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public.zone_id
}

resource "aws_acm_certificate_validation" "api" {
  provider = aws.virginia
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}