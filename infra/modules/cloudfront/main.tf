
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_origin_request_policy" "api_forward_all" {
  name = "${var.name}-api-forward-all"

  cookies_config { cookie_behavior = "all" }
  headers_config { header_behavior = "allViewer" }
  query_strings_config { query_string_behavior = "all" }
}

resource "aws_cloudfront_distribution" "api" {
  enabled     = true
  price_class = "PriceClass_100"

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  
  default_cache_behavior {
  target_origin_id       = "alb-origin"
  viewer_protocol_policy = "redirect-to-https"

  allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  cached_methods  = ["GET", "HEAD", "OPTIONS"]

  cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
  origin_request_policy_id = aws_cloudfront_origin_request_policy.api_forward_all.id
}

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}
