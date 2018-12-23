locals {
  www_domain_name = "www.${var.domain_name}"
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

  aliases = ["${var.domain_name}", "${local.www_domain_name}"]
  default_root_object = "index.html"

  enabled = true
  http_version = "http2"
  is_ipv6_enabled = true

  price_class = "PriceClass_100" // Europe, US and Canada

  custom_error_response {
    error_code = "404"
    response_code = "404"
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}