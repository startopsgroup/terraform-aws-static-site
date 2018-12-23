locals {
  root_bucket_name = "${var.domain_name}"
  www_bucket_name = "www.${var.domain_name}"
  log_bucket_name = "logs.${var.domain_name}"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${local.log_bucket_name}"
  acl = "log-delivery-write"
  force_destroy = true
}

resource "aws_s3_bucket" "root_bucket" {
  bucket = "${local.root_bucket_name}"
  depends_on = ["aws_s3_bucket.log_bucket"]

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  acl = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${local.root_bucket_name}/*"]
    }
  ]
}
POLICY

  logging {
    target_bucket = "${local.log_bucket_name}"
    target_prefix = "root/"
  }
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "${local.www_bucket_name}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }
}
