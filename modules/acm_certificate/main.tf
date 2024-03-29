resource "aws_acm_certificate" "certificate" {
  domain_name = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
  tags = {
    StaticSite = "${var.static_site_tag}"
  }
}

resource "aws_route53_record" "validation_record" {
  name = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.hosted_zone_id}"
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.validation_record.fqdn}"]
}
