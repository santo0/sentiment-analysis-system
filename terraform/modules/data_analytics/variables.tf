variable "existing_iam_role_arn" {
  description = "The ARN of the existing IAM role to be used by Athena"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Athena query results"
  type        = string
  default     = "value"
}

variable "athena_database_name" {
  description = "The name of the Athena database"
  type        = string
  default     = "tweetsdb"
}

variable "athena_table_name" {
  description = "The name of the Athena table"
  type        = string
  default     = "cust_test_table"
}

variable "s3_table_location" {
  description = "The S3 location for the Athena table data"
  type        = string
  default     = "s3://ccbda-custbucket-test/product1/processed/"
}
