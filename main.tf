provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias = "use1"
  region = "us-east-1"
}

locals {
  root_domain_name = "${var.domain_name}"
  www_domain_name = "www.${var.domain_name}"
}

data "aws_route53_zone" "hosted_zone" {
  name = "${local.root_domain_name}."
}

module "website" {
  source = "./s3_website"
  domain_name = "${local.root_domain_name}"
}

module "email-receiving" {
  source = "./ses_email_receiving"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  domain_name = "${local.root_domain_name}"

  providers = {
    aws = "aws.use1"
  }
}

module "certificate" {
  source = "./acm_certificate"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  domain_name = "${local.root_domain_name}"

  providers = {
    aws = "aws.use1"
  }
}

module "root_cdn" {
  source = "./cloudfront_distribution"
  website_endpoint = "${module.website.root_website_endpoint}"
  domain_name = "${local.root_domain_name}"
  acm_certificate_arn = "${module.certificate.acm_certificate_arn}"
  not_found_path = "${var.not_found_path}"
}

module "www_cdn" {
  source = "./cloudfront_distribution"
  website_endpoint = "${module.website.www_website_endpoint}"
  domain_name = "${local.www_domain_name}"
  acm_certificate_arn = "${module.certificate.acm_certificate_arn}"
  not_found_path = "${var.not_found_path}"
}

module "root_dns_record" {
  source = "./route53_record"
  domain_name = "${local.root_domain_name}"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  cdn_domain_name = "${module.root_cdn.domain_name}"
  cdn_hosted_zone_id = "${module.root_cdn.hosted_zone_id}"
}

module "www_dns_record" {
  source = "./route53_record"
  domain_name = "${local.www_domain_name}"
  hosted_zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  cdn_domain_name = "${module.www_cdn.domain_name}"
  cdn_hosted_zone_id = "${module.www_cdn.hosted_zone_id}"
}
