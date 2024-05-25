output "customer_1_bucket" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.customer_1_bucket.bucket
}