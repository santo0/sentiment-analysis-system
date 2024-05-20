output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.athena_results.bucket
}

output "athena_workgroup_name" {
  description = "The name of the Athena workgroup"
  value       = aws_athena_workgroup.example.name
}

output "athena_database_name" {
  description = "The name of the Athena database"
  value       = aws_athena_database.example.name
}

output "athena_table_name" {
  description = "The name of the Athena table"
  value       = aws_glue_catalog_table.example.name
}
