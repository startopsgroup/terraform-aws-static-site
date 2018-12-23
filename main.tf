provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias = "use1"
  region = "us-east-1"
}

data "aws_route53_zone" "hosted_zone" {
  name = "${var.domain_name}."
}

module "website" {
  source = "./s3_website"
  domain_name = "${var.domain_name}"
}

module "email-receiving" {
  source = "./ses_email_receiving"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  domain_name = "${var.domain_name}"

  providers = {
    aws = "aws.use1"
  }
}

module "certificate" {
  source = "./acm_certificate"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  domain_name = "${var.domain_name}"

  providers = {
    aws = "aws.use1"
  }
}

module "cdn" {
  source = "./cloudfront_distribution"
  website_endpoint = "${module.website.website_endpoint}"
  domain_name = "${var.domain_name}"
  acm_certificate_arn = "${module.certificate.acm_certificate_arn}"
  not_found_path = "${var.not_found_path}"
}

module "dns_record" {
  source = "./route53_record"
  domain_name = "${var.domain_name}"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  cdn_domain_name = "${module.cdn.domain_name}"
  cdn_hosted_zone_id = "${module.cdn.hosted_zone_id}"
}
