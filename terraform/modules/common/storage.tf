resource "aws_s3_bucket" "raw_tweets_bucket" {
  bucket = var.raw_tweets_bucket_name
}

resource "aws_s3_bucket_public_access_block" "raw_public_access" {
  bucket = aws_s3_bucket.raw_tweets_bucket.id

  block_public_acls   = false
  block_public_policy = false
}


resource "aws_s3_bucket" "derived_data_bucket" {
  bucket = var.derived_data_bucket_name
}

resource "aws_s3_bucket_public_access_block" "derived_public_access" {
  bucket = aws_s3_bucket.derived_data_bucket.id

  block_public_acls   = false
  block_public_policy = false
}


resource "aws_s3_bucket" "customer_1_bucket" {
  bucket = "ccbda-customer-1-bucket" # name must be unique in all AWS
}

resource "aws_s3_bucket_public_access_block" "customer_1_public_access" {
  bucket = aws_s3_bucket.customer_1_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket" "customer_2_bucket" {
  bucket = "ccbda-customer-2-bucket" # name must be unique in all AWS
}

resource "aws_s3_bucket_public_access_block" "customer_2_public_access" {
  bucket = aws_s3_bucket.customer_2_bucket.id

  block_public_acls   = false
  block_public_policy = false
}
