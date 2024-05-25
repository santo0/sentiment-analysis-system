data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# resource "aws_s3_object" "processed_data" {
#   bucket = var.customer_1_bucket
#   key    = "/what/processed/processed_data.parquet"
#   source = "./modules/data_analytics/data/202405101559171535676626.parquet"
#   acl    = "private"
# }

resource "aws_athena_workgroup" "sentiment-analysis-athena-wrkg" {
  name = "athena-workgroup"
  state = "ENABLED"

  configuration {
    execution_role = data.aws_iam_role.lab_role.arn
    # enforce_workgroup_configuration    = true
    # publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.customer_1_bucket}/analytics/wrkg/"
    }
  }
}

resource "aws_athena_database" "athena-db" {
  name   = var.athena_database_name
  # set the bucket to an specific folder of the output bucket
  # bucket = "s3://${aws_s3_bucket.data_analytics_output_bucket.bucket}/athena-results/db/"
  bucket = var.customer_1_bucket

  # depends_on = [
  #   null_resource.delete_view
  # ]
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
      type = "timestamp"
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
    columns {
      name = "timestamp"
      type = "timestamp"
    }
  }
}

resource "null_resource" "create_view" {
  provisioner "local-exec" {
    command = <<EOT
      aws athena start-query-execution \
        --region us-east-1 \
        --query-string "CREATE OR REPLACE VIEW ${var.athena_database_name}.emotions_view AS SELECT 'sadness' AS emotion, SUM(sadness) AS value FROM ${var.athena_database_name}.${var.athena_table_name} UNION ALL SELECT 'joy' AS emotion, SUM(joy) AS value FROM ${var.athena_database_name}.${var.athena_table_name} UNION ALL SELECT 'love' AS emotion, SUM(love) AS value FROM ${var.athena_database_name}.${var.athena_table_name} UNION ALL SELECT 'anger' AS emotion, SUM(anger) AS value FROM ${var.athena_database_name}.${var.athena_table_name} UNION ALL SELECT 'fear' AS emotion, SUM(fear) AS value FROM ${var.athena_database_name}.${var.athena_table_name} UNION ALL SELECT 'surprise' AS emotion, SUM(surprise) AS value FROM ${var.athena_database_name}.${var.athena_table_name};" \
        --query-execution-context Database=${var.athena_database_name} \
        --result-configuration "OutputLocation=s3://${var.customer_1_bucket}/what/analytics/query-results/"
    EOT
  }

  depends_on = [aws_glue_catalog_table.sentiment-analysis-ct]
}

resource "aws_glue_job" "parse_date_job" {
  name     = var.glue_job_name
  role_arn = data.aws_iam_role.lab_role.arn

  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"                        = var.temporary_directory
    "--enable-metrics"                 = "true"
    "--enable-continuous-log-filter"   = "true"
    "--job-bookmark-option"            = "job-bookmark-disable"
  }

  max_retries          = var.max_retries
  timeout              = var.timeout
  glue_version         = "4.0"
  number_of_workers    = 2
  worker_type          = "G.1X"
  execution_class      = "STANDARD"
  tags = {
    Name = "ParseDateJob"
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }
}

resource "aws_glue_trigger" "parse_job_trigger" {
  name     = "parse-trigger"
  type     = "SCHEDULED"
  schedule = "rate(10 minutes)"  # This expression schedules the job to run every 10 minutes

  actions {
    job_name = aws_glue_job.parse_date_job.name
  }

  start_on_creation = true
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


# Define the QuickSight Data Source for Athena
resource "aws_quicksight_data_source" "quicksight-data-source" {
  data_source_id = "quicksight-athena-source"
  name           = "ccbda-project"
  type           = "ATHENA"
  parameters {
    athena {
      work_group = "athena-workgroup"
    }
  }

  # permission {
  #   principal = "arn:aws:quicksight:us-east-1:123456789012:user/default/quicksight-user"
  #   actions   = ["quicksight:DescribeDataSource", "quicksight:DescribeDataSourcePermissions", "quicksight:PassDataSource"]
  # }

  aws_account_id = var.account_id
}

# Define the QuickSight Dataset
resource "aws_quicksight_data_set" "table-data" {
  data_set_id = "table-data-athena-dataset"
  name        = "table-data-athena-dataset"
  import_mode = "SPICE"

  physical_table_map {
    physical_table_map_id = var.athena_table_name
    relational_table {
      data_source_arn = aws_quicksight_data_source.quicksight-data-source.arn
      name          = var.athena_table_name
      input_columns {
      name = "age"
      type = "integer"
      }
      input_columns {
        name = "country"
        type = "string"
      }
      input_columns {
        name = "date"
        type = "string"
      }
      input_columns {
        name = "flag"
        type = "string"
      }
      input_columns {
        name = "gender"
        type = "string"
      }
      input_columns {
        name = "ids"
        type = "integer"
      }
      input_columns {
        name = "target"
        type = "integer"
      }
      input_columns {
        name = "text"
        type = "string"
      }
      input_columns {
        name = "user"
        type = "string"
      }
      input_columns {
        name = "sadness"
        type = "decimal"
      }
      input_columns {
        name = "joy"
        type = "decimal"
      }
      input_columns {
        name = "love"
        type = "decimal"
      }
      input_columns {
        name = "anger"
        type = "decimal"
      }
      input_columns {
        name = "fear"
        type = "decimal"
      }
      input_columns {
        name = "surprise"
        type = "decimal"
      }
    }
  }
}

# Define the QuickSight dataset
resource "aws_quicksight_data_set" "emotions-view" {
  data_set_id = "emotions-view-athena-dataset"
  name        = "emotions-view-athena-dataset"
  import_mode = "SPICE"

  physical_table_map {
    physical_table_map_id = "emotions_view"
    relational_table {
      data_source_arn = aws_quicksight_data_source.quicksight-data-source.arn
      name          = "emotions_data"
      input_columns {
        name = "sadness"
        type = "decimal"
      }
      input_columns {
        name = "joy"
        type = "decimal"
      }
      input_columns {
        name = "love"
        type = "decimal"
      }
      input_columns {
        name = "anger"
        type = "decimal"
      }
      input_columns {
        name = "fear"
        type = "decimal"
      }
      input_columns {
        name = "surprise"
        type = "decimal"
      }
    }
  }
}
