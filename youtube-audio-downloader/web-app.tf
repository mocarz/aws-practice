
resource "aws_s3_bucket" "web-app" {
  bucket        = "yt-dlp-app-${lower(data.aws_caller_identity.current.user_id)}"
  force_destroy = true
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  price_class         = "PriceClass_100"
  wait_for_deployment = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.web-app.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "${aws_s3_bucket.web-app.bucket}.s3-website-${local.aws_region}.amazonaws.com"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", ]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.web-app.bucket}.s3-website-${local.aws_region}.amazonaws.com"

    forwarded_values {
      query_string = false

      cookies {
        forward = "all"
      }
    }


    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = aws_s3_bucket.web-app.bucket_domain_name
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
