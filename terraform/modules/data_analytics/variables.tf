variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Athena query results"
  type        = string
  default     = "ccbda-analytics-output-bucket-111"
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
  default     = "s3://ccbda-analytics-output-bucket-111/product1/processed/"
}

variable "glue_job_name" {
  description = "The name of the Glue job"
  type        = string
  default = "ParseDateJob"
}

variable "glue_s3_bucket_name" {
  description = "The name of the S3 bucket for Glue assets"
  type        = string
  default = "aws-glue-assets-bucket-111"
}

variable "script_location" {
  description = "value of the ParseDateJob.py script location"
  type = string
  default = "s3://aws-glue-assets-bucket-111/scripts/ParseDateJob.py"
}

variable "temporary_directory" {
  description = "value of the temporary directory for the Glue job"
  type = string
  default = "s3://aws-glue-assets-bucket-111/temporary/"
}

variable "spark_path" {
  description = "value of the Spark history logs path"
  type = string
  default = "s3://aws-glue-assets-bucket-111/sparkHistoryLogs/"
}

variable "max_retries" {
  description = "value of the maximum retries for the Glue job"
  type = number
  default = 0
}

variable "timeout" {
  description = "value of the timeout for the Glue job"
  type = number
  default = 2880
}

variable "max_concurrent_runs" {
  description = "value of the maximum concurrent runs for the Glue job"
  type = number
  default = 1
}
