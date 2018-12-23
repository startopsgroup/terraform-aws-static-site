output "website_endpoint" {
  value = "${aws_s3_bucket.root_bucket.website_endpoint}"
}