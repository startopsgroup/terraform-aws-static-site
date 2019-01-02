# terraform-aws-static-site

Provision a static website hosted through S3 in AWS.

## Features
- Creates SSL certificate to enable HTTPS
- Sets up email forwarding for domain to S3 bucket
- Redirects www. requests to root domain

## Prerequisites
- Create hosted zone for intended domain in Route 53
- Set the domain's nameservers to point to the AWS nameservers listed in the hosted zone

## Usage
```
# terraform.tf

provider "aws" {
  region = "eu-west-2"
}

module "static_site" {
  source = "github.com/jamesturner/terraform-aws-static-site"

  domain_name = "example.com"

  not_found_path = "/404.html"
  not_found_response_code = "404"
}
```