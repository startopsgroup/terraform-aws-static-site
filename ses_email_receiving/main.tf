data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  email_bucket_name = "email-receiving.${var.domain_name}"
  account_id = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_ses_domain_identity" "domain_identity" {
  domain = "${var.domain_name}"
}

resource "aws_route53_record" "verification_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "_amazonses.${var.domain_name}"
  type = "TXT"
  ttl = "600"
  records = ["${aws_ses_domain_identity.domain_identity.verification_token}"]
}

resource "aws_route53_record" "mx_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.domain_name}"
  type = "MX"
  ttl = "1800"
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
}

resource "aws_ses_receipt_rule" "receipt_rule" {
  name = "${var.domain_name}-inbound-email-s3"
  rule_set_name = "default-rule-set"
  enabled = true
  depends_on = ["aws_s3_bucket.email_receiving_bucket"]

  s3_action {
    bucket_name = "${local.email_bucket_name}"
    position = 1
  }
}

resource "aws_s3_bucket" "email_receiving_bucket" {
  bucket = "${local.email_bucket_name}"
  acl = "log-delivery-write"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.email_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "${local.account_id}"
                }
            }
        }
    ]
}
POLICY
}