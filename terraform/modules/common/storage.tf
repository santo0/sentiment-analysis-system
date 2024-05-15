resource "aws_s3_bucket" "raw_tweets_bucket" {
  bucket = "ccbda-raw-tweets-bucket-alis" # name must be unique in all AWS
}

resource "aws_s3_bucket_public_access_block" "raw_public_access" {
  bucket = aws_s3_bucket.raw_tweets_bucket.id

  block_public_acls   = false
  block_public_policy = false
}


resource "aws_s3_bucket" "derived_data_bucket" {
  bucket = "ccbda-derived-data-bucket-alis"
}

resource "aws_s3_bucket_public_access_block" "derived_public_access" {
  bucket = aws_s3_bucket.derived_data_bucket.id

  block_public_acls   = false
  block_public_policy = false
}
