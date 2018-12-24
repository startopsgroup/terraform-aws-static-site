output "root_website_endpoint" {
  value = "${aws_s3_bucket.root_bucket.website_endpoint}"
}

output "www_website_endpoint" {
  value = "${aws_s3_bucket.www_bucket.website_endpoint}"
}