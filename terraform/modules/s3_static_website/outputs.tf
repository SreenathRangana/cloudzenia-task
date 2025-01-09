output "s3_bucket_name" {
  value = aws_s3_bucket.static_website.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_website_cdn.domain_name
}
