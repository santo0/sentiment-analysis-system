resource "aws_s3_bucket" "ccbda-system-config" {
  bucket = var.ccbda-system-config
}

resource "aws_s3_bucket_public_access_block" "ccbda-system-config_public_access" {
  bucket = aws_s3_bucket.ccbda-system-config.id

  block_public_acls   = false
  block_public_policy = false
}

# upload all the files in the system_config directory to the s3 bucket
resource "aws_s3_object" "api_data" {
  bucket = var.ccbda-system-config
  # upload all the files in ingestion_pipeline/mock_twitter_api/data/splitted/*.csv
  for_each = fileset("../ingestion_pipeline/mock_twitter_api/data/splitted/", "**/*")
  source = "../ingestion_pipeline/mock_twitter_api/data/splitted/${each.value}"
  key    = "/twitter_dataset/${each.value}"
  acl    = "private"

  depends_on = [ aws_s3_bucket.ccbda-system-config ]
}

resource "aws_s3_bucket" "customer_1_bucket" {
  bucket = var.customer_1_bucket
}

resource "aws_s3_bucket_public_access_block" "customer_1_public_access" {
  bucket = aws_s3_bucket.customer_1_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

# resource "aws_s3_bucket" "customer_2_bucket" {
#   bucket = var.customer_2_bucket
# }

# resource "aws_s3_bucket_public_access_block" "customer_2_public_access" {
#   bucket = aws_s3_bucket.customer_2_bucket.id

#   block_public_acls   = false
#   block_public_policy = false
# }
