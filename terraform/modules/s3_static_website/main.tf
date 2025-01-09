resource "aws_s3_bucket" "static_website" {
  bucket        = var.bucket_name
  acl           = "public-read"
  force_destroy = true
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = var.tags
}

resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "static_website_cdn" {
  origin {
    domain_name = "${aws_s3_bucket.static_website.bucket_regional_domain_name}"
    origin_id   = "s3-origin"
  }

  enabled             = true
  is_ipv6_enabled      = true
  default_root_object  = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      headers      = ["*"]
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class       = "PriceClass_100"
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  tags = var.tags
}