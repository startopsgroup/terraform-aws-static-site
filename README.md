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
terraform apply \
    -var 'region=eu-west-2' \
    -var 'domain_name=example.com' \
    -var 'not_found_path=/404.html'
```