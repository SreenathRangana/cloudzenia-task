variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

variable "geo_restriction_type" {
  description = "Geo restriction type for CloudFront (whitelist/blacklist)"
  type        = string
  default     = "blacklist"
}

variable "geo_restriction_locations" {
  description = "List of countries to apply geo-restriction"
  type        = list(string)
  default     = ["CN"] # Example: Blocking China
}
