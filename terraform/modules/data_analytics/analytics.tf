# # create the variable for the data analytics output bucket name
# variable "data_analytics_output_bucket_name" {
#   type = string
# }

# variable "athena_database_name" {
#   type = string
# }

# variable "athena_table_name" {
#   type = string
# }

# variable "s3_table_location" {
#   type = string
# }

resource "aws_s3_bucket" "data_analytics_output_bucket" {
  bucket = var.s3_bucket_name

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_athena_workgroup" "sentiment-analysis-athena-wrkg" {
  name = "athena-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_analytics_output_bucket.bucket}/results/"
    }
  }
}

resource "aws_athena_database" "athena-db" {
  name   = var.athena_database_name
  bucket = aws_s3_bucket.data_analytics_output_bucket.bucket

   depends_on = [
    null_resource.delete_view
  ]

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_glue_catalog_table" "sentiment-analysis-ct" {
  database_name = aws_athena_database.athena-db.name
  name          = var.athena_table_name

  table_type    = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL              = "TRUE"
    "classification" = "parquet"
  }

  storage_descriptor {
    location      = var.s3_table_location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name            = var.athena_table_name
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "age"
      type = "bigint"
    }
    columns {
      name = "country"
      type = "string"
    }
    columns {
      name = "date"
      type = "string"
    }
    columns {
      name = "flag"
      type = "string"
    }
    columns {
      name = "gender"
      type = "string"
    }
    columns {
      name = "ids"
      type = "bigint"
    }
    columns {
      name = "target"
      type = "bigint"
    }
    columns {
      name = "text"
      type = "string"
    }
    columns {
      name = "user"
      type = "string"
    }
    columns {
      name = "sadness"
      type = "double"
    }
    columns {
      name = "joy"
      type = "double"
    }
    columns {
      name = "love"
      type = "double"
    }
    columns {
      name = "anger"
      type = "double"
    }
    columns {
      name = "fear"
      type = "double"
    }
    columns {
      name = "surprise"
      type = "double"
    }
  }
}

resource "null_resource" "create_view" {
  provisioner "local-exec" {
    command = <<EOT
      aws athena start-query-execution \
        --region us-east-1 \
        --query-string "CREATE OR REPLACE VIEW ${var.athena_database_name}.emotion_sums_long AS SELECT 'sadness' AS emotion, SUM(sadness) AS value FROM ${var.athena_database_name}.cust_test_table UNION ALL SELECT 'joy' AS emotion, SUM(joy) AS value FROM ${var.athena_database_name}.cust_test_table UNION ALL SELECT 'love' AS emotion, SUM(love) AS value FROM ${var.athena_database_name}.cust_test_table UNION ALL SELECT 'anger' AS emotion, SUM(anger) AS value FROM ${var.athena_database_name}.cust_test_table UNION ALL SELECT 'fear' AS emotion, SUM(fear) AS value FROM ${var.athena_database_name}.cust_test_table UNION ALL SELECT 'surprise' AS emotion, SUM(surprise) AS value FROM ${var.athena_database_name}.cust_test_table;" \
        --query-execution-context Database=${var.athena_database_name} \
        --result-configuration "OutputLocation=s3://${aws_s3_bucket.data_analytics_output_bucket.bucket}/query-results/"
    EOT
  }

  depends_on = [aws_glue_catalog_table.sentiment-analysis-ct]
}

resource "null_resource" "delete_view" {
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      aws athena start-query-execution \
        --region us-east-1 \
        --query-string "DROP VIEW IF EXISTS tweetsdb.emotion_sums_long;" \
        --query-execution-context Database=tweetsdb \
        --result-configuration "OutputLocation=s3://ccbda-analytics-output-bucket/query-results/"
    EOT
  }

}

# Code to run queries on the Athena table
# resource "null_resource" "run_custom_query" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws athena start-query-execution \
#         --query-string "SELECT * FROM ${aws_glue_catalog_table.cust_test_table.database_name}.${aws_glue_catalog_table.cust_test_table.name} LIMIT 10;" \
#         --query-execution-context Database=${aws_glue_catalog_table.cust_test_table.database_name} \
#         --result-configuration "OutputLocation=s3://${aws_s3_bucket.query_results.bucket}/query-results/"
#     EOT
#   }

#   depends_on = [aws_glue_catalog_table.cust_test_table]
# }