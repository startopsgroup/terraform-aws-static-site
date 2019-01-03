output "s3_website_endpoint" {
  value = "${module.website.root_website_endpoint}"
}

output "root_cloudfront_distribution_id" {
  value = "${module.root_cdn.distribution_id}"
}

output "www_cloudfront_distribution_id" {
  value = "${module.www_cdn.distribution_id}"
}
