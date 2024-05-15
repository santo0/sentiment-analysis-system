# create the variable for the data analytics output bucket name
variable "data_analytics_output_bucket_name" {
  type = string
}

# create an s3 bucket for storing the output of the data analytics jo
resource "aws_s3_bucket" "data_analytics_output_bucket" {
  bucket = "${var.data_analytics_output_bucket_name}"
}


# Create Glue Data Catalog database
resource "aws_glue_catalog_database" "ccbda-glue-database" {
  name = "ccbda-glue-database"
}

# Create Athena Workgroup
resource "aws_athena_workgroup" "ccbda-athena-workgroup" {
  name = "ccbda-athena-workgroup"
}

# Output the Athena Workgroup details
output "athena_workgroup_details" {
  value = aws_athena_workgroup.ccbda-athena-workgroup
}

# Create Glue Crawler
resource "aws_glue_crawler" "ccbda-glue-crawler" {
  name             = "ccbda-glue-crawler"
  database_name    = aws_glue_catalog_database.ccbda-glue-database.name
  role             = "arn:aws:iam::211125730795:role/LabRole"
  table_prefix     = "my_data_"
  s3_target {
    path = "s3://${aws_s3_bucket.data_analytics_output_bucket.bucket}/"
  }
  depends_on = [aws_glue_catalog_database.ccbda-glue-database]
}

# Output the Glue Crawler details
output "glue_crawler_details" {
  value = aws_glue_crawler.ccbda-glue-crawler
}