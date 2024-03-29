locals {
  origin_id = "origin-s3-${var.domain_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_id   = "${local.origin_id}"
    domain_name = "${var.website_endpoint}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  aliases = ["${var.domain_name}"]

  enabled = true
  http_version = "http2"
  is_ipv6_enabled = true

  custom_error_response {
    error_code = "404"
    response_code = "${var.not_found_response_code}"
    response_page_path = "${var.not_found_path}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress = true
  }

  viewer_certificate {
    acm_certificate_arn = "${var.acm_certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "${var.log_bucket_name}"
    prefix          = "${var.log_prefix}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    StaticSite = "${var.static_site_tag}"
  }
}
