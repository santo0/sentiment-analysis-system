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
