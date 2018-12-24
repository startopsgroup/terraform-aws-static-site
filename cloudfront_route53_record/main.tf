resource "aws_route53_record" "ipv4_alias" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.domain_name}"
  type = "A"

  alias = {
    name = "${var.cdn_domain_name}"
    zone_id = "${var.cdn_hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6_alias" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.domain_name}"
  type = "AAAA"

  alias = {
    name = "${var.cdn_domain_name}"
    zone_id = "${var.cdn_hosted_zone_id}"
    evaluate_target_health = false
  }
}
