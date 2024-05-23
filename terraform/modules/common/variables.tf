variable "raw_tweets_bucket_name" {
  description = "The name of the S3 bucket for raw tweets"
  type        = string
  default     = "ccbda-raw-tweets-bucket-111"
}

variable "derived_data_bucket_name" {
  description = "The name of the S3 bucket for derived data"
  type        = string
  default     = "ccbda-derived-data-bucket-111"
}