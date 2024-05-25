# output "athena_workgroup_name" {
#   description = "The name of the Athena workgroup"
#   value       = aws_athena_workgroup.sentiment-analysis-athena-wrkg.name
# }

output "athena_database_name" {
  description = "The name of the Athena database"
  value       = aws_athena_database.athena-db.name
}

output "athena_table_name" {
  description = "The name of the Athena table"
  value       = aws_glue_catalog_table.sentiment-analysis-ct.name
}
