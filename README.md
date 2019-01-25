# terraform-aws-static-site

Provision a static website hosted through S3 in AWS.

## Features
- Creates SSL certificate to enable HTTPS
- Redirects www. requests to root domain
- Uses CloudFront to serve content

## Prerequisites
- Create hosted zone for intended domain in Route 53
- Set the domain's nameservers to point to the AWS nameservers listed in the hosted zone

## Usage
```
# terraform.tf

provider "aws" {
  region = "eu-west-2"
}

module "static-site" {
  source  = "jamesturner/static-site/aws"
  version = "0.1.0"

  domain_name = "example.com"

  index_document = "index.html"
  error_document = "error.html"

  not_found_path = "/404.html"
  not_found_response_code = "404"
}
```
