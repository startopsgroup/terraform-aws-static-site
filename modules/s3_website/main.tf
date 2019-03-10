locals {
  root_bucket_name = "${var.domain_name}"
  www_bucket_name = "www.${var.domain_name}"
}

resource "aws_s3_bucket" "root_bucket" {
  bucket = "${local.root_bucket_name}"

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
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
    target_bucket = "${var.log_bucket_name}"
    target_prefix = "root/"
  }

  tags {
    StaticSite = "${var.static_site_tag}"
  }
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "${local.www_bucket_name}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }

  tags {
    StaticSite = "${var.static_site_tag}"
  }
}
