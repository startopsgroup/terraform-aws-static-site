variable "domain_name" {
  description = "The domain name that the website will be nested under. Must be the root domain and not include www. (e.g. google.com)"
}

variable "not_found_path" {
  description = "The path to the file that CloudFront should return to the user to if they visit a page that does not exist."
}

variable "not_found_response_code" {
  description = "The HTTP status code that should be returned when the user attempts to visit a page that doesn't exist. This will usually be 404 unless the website is a SPA, in which case it may be desirable to return 200 and handle the not found case on the client side"
}
