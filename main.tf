#---------------------------------------------------------------------------------------
# Terraform version should be used by this template
#---------------------------------------------------------------------------------------
terraform {

  # Set S3 as backend of the state file
  backend "s3" {}

  required_version = ">= 0.12.1,<= 0.12.5"

  required_providers {
    aws = "~> 2.15.0"
  }
}

locals {
  root_domain_name = var.domain_name
  www_domain_name = "www.${var.domain_name}"
  log_bucket_name = "logs.${var.domain_name}"
}

data "aws_route53_zone" "hosted_zone" {
  name = "${local.root_domain_name}."
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = local.log_bucket_name
  acl = "log-delivery-write"
  force_destroy = true

  lifecycle_rule {
    id      = "cleanup-logs"
    enabled = true

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      days = 1
    }
  }

  tags {
    StaticSite = var.static_site_tag
  }
}

module "website" {
  source = "modules/s3_website"
  domain_name = local.root_domain_name
  log_bucket_name = aws_s3_bucket.log_bucket.id
  index_document = var.index_document
  error_document = var.error_document
  static_site_tag = var.static_site_tag
}

module "certificate" {
  source = "modules/acm_certificate"
  hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
  domain_name = local.root_domain_name
  static_site_tag = var.static_site_tag
}

module "root_cdn" {
  source = "modules/cloudfront_distribution"
  website_endpoint = module.website.root_website_endpoint
  domain_name = local.root_domain_name
  acm_certificate_arn = module.certificate.acm_certificate_arn
  not_found_path = var.not_found_path
  not_found_response_code = var.not_found_response_code
  log_bucket_name = aws_s3_bucket.log_bucket.bucket_domain_name
  log_prefix = "cf-logs/"
  static_site_tag = var.static_site_tag
}

module "www_cdn" {
  source = "modules/cloudfront_distribution"
  website_endpoint = "${module.website.www_website_endpoint}"
  domain_name = local.www_domain_name
  acm_certificate_arn = module.certificate.acm_certificate_arn
  not_found_path = var.not_found_path
  not_found_response_code = var.not_found_response_code
  log_bucket_name = aws_s3_bucket.log_bucket.bucket_domain_name
  log_prefix = "cf-logs/"
  static_site_tag = var.static_site_tag
}

module "root_dns_record" {
  source = "modules/cloudfront_route53_record"
  domain_name = local.root_domain_name
  hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
  cdn_domain_name = module.root_cdn.domain_name
  cdn_hosted_zone_id = module.root_cdn.hosted_zone_id
}

module "www_dns_record" {
  source = "modules/cloudfront_route53_record"
  domain_name = local.www_domain_name
  hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
  cdn_domain_name = module.www_cdn.domain_name
  cdn_hosted_zone_id = module.www_cdn.hosted_zone_id
}
