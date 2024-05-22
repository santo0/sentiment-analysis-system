resource "aws_s3_bucket" "data_analytics_output_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_object" "processed_data" {
  bucket = var.s3_bucket_name
  key    = "/product1/processed/processed_data.parquet"
  source = "./modules/data_analytics/data/202405101559171535676626.parquet"
  acl    = "private"

  depends_on = [ aws_s3_bucket.data_analytics_output_bucket ]
}

resource "aws_athena_workgroup" "sentiment-analysis-athena-wrkg" {
  name = "athena-workgroup"
  state = "ENABLED"

  configuration {
    execution_role = var.iam_role_arn
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_analytics_output_bucket.bucket}/"
    }
  }
}

resource "aws_athena_database" "athena-db" {
  name   = var.athena_database_name
  bucket = aws_s3_bucket.data_analytics_output_bucket.bucket


  depends_on = [
    null_resource.delete_view
  ]
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
        --result-configuration "OutputLocation=s3://ccbda-analytics-output-bucket/results/"
    EOT
  }

}

resource "aws_glue_job" "parse_date_job" {
  name     = var.glue_job_name
  role_arn = var.iam_role_arn

  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"                = var.temporary_directory
    "--enable-metrics"         = "true"
    "--enable-continuous-log-filter" = "true"
    "--job-bookmark-option"    = "job-bookmark-disable"
    # "--additional-python-modules" = var.python_path
  }

  max_retries          = var.max_retries
  timeout              = var.timeout
  glue_version         = "4.0"
  number_of_workers    = 10
  worker_type          = "G.1X"
  execution_class      = "STANDARD"
  tags = {
    Name = "ParseDateJob"
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }
}

# create an s3 bucket with glue_s3_bucket_name name
resource "aws_s3_bucket" "glue_s3_bucket" {
  bucket = var.glue_s3_bucket_name
}

# create a aws_s3_bucket_object resource to upload the script to the S3 bucket
resource "aws_s3_object" "glue_script" {
  bucket = var.glue_s3_bucket_name
  key    = "/scripts/ParseDateJob.py"
  source = "./modules/data_analytics/scripts/ParseDateJob.py"
  acl    = "private"

  depends_on = [ aws_s3_bucket.glue_s3_bucket ]
}

# resource "aws_quicksight_data_source" "emotion_sums_long" {
#   data_source_id = "emotion_sums_long-data-source"
#   name           = "emotion_sums_long"
#   type           = "ATHENA"

#   parameters {
#     athena {
#       work_group = aws_athena_workgroup.sentiment-analysis-athena-wrkg.name
#     }
#   }
# }

# resource "aws_quicksight_data_set" "example" {
#   data_set_id   = "example-data-set"
#   name          = "example"
#   import_mode   = "SPICE"

#   column {
#     name = "example-column"
#     type = "STRING"
#   }

#   permissions {
#     principal = aws_iam_role.quicksight_role.arn
#     actions   = ["quicksight:DescribeDataSet", "quicksight:DescribeDataSetPermissions", "quicksight:PassDataSet"]
#   }
# }

# resource "aws_quicksight_template" "example" {
#   template_id = "example-template"
#   name        = "example"
  
#   source_entity {
#     source_analysis {
#       arn = "arn:aws:quicksight:us-east-1:123456789012:analysis/example-analysis"
#     }
#   }

#   permissions {
#     principal = aws_iam_role.quicksight_role.arn
#     actions   = ["quicksight:DescribeTemplate", "quicksight:DescribeTemplatePermissions", "quicksight:PassTemplate"]
#   }
# }

# resource "aws_quicksight_dashboard" "example" {
#   dashboard_id        = "example-dashboard"
#   name                = "Example Dashboard"
#   version_description = "Initial version"

#   source_entity {
#     source_template {
#       arn = aws_quicksight_template.example.arn
#       data_set_references {
#         data_set_arn         = aws_quicksight_data_set.example.arn
#         data_set_placeholder = "1"
#       }
#     }
#   }

#   permissions {
#     principal = aws_iam_role.quicksight_role.arn
#     actions   = ["quicksight:DescribeDashboard", "quicksight:ListDashboardVersions", "quicksight:UpdateDashboardPermissions", "quicksight:QueryDashboard", "quicksight:DeleteDashboard", "quicksight:UpdateDashboard", "quicksight:ShareDashboard", "quicksight:RestoreDashboard", "quicksight:CreateDashboard"]
#   }
# }

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