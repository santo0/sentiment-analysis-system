variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Athena query results"
  type        = string
  default     = "glue"
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

variable "glue_job_name" {
  default = "ParseDateJob"
}

variable "iam_role_arn" {
  description = "extisting LabRole"
  default = "arn:aws:iam::211125730795:role/LabRole"
}

variable "script_location" {
  default = "s3://aws-glue-assets-test-dsfha/scripts/ParseDateJob.py"
}

variable "temporary_directory" {
  default = "s3://aws-glue-assets-test-dsfha/temporary/"
}

variable "python_path" {
  default = "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_common.py,s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_to_timestamp.py"
}

variable "spark_path" {
  default = "s3://aws-glue-assets-test-dsfha/sparkHistoryLogs/"
}

variable "max_retries" {
  default = 0
}

variable "timeout" {
  default = 2880
}

variable "max_concurrent_runs" {
  default = 1
}

variable "glue_s3_bucket_name" {
  default = "aws-glue-assets-test-dsfha"
}