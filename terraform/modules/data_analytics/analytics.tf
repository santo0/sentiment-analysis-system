# create the variable for the data analytics output bucket name
variable "data_analytics_output_bucket_name" {
  type = string
}

variable "athena_database_name" {
  type = string
}

variable "athena_table_name" {
  type = string
}

variable "s3_table_location" {
  type = string
}

resource "aws_s3_bucket" "data_analytics_output_bucket" {
  bucket = "${var.data_analytics_output_bucket_name}"

  lifecycle {
    prevent_destroy = true
  }
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
  bucket = aws_s3_bucket.athena_results.bucket
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

# resource "aws_iam_role" "athena" {
#   name = "athena-s3-access-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "athena.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_policy" "athena_s3_access" {
#   name        = "athena-s3-access-policy"
#   description = "Policy to allow Athena to access S3 buckets"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ],
#         Effect   = "Allow",
#         Resource = "${aws_s3_bucket.athena_results.arn}/*"
#       },
#       {
#         Action   = "s3:ListBucket",
#         Effect   = "Allow",
#         Resource = aws_s3_bucket.athena_results.arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_athena_s3_access" {
#   role       = aws_iam_role.athena.name
#   policy_arn = aws_iam_policy.athena_s3_access.arn
# }

# resource "aws_s3_bucket_policy" "quicksight_access" {
#   bucket = aws_s3_bucket.athena_results.bucket
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ],
#         Effect   = "Allow",
#         Resource = [
#           aws_s3_bucket.athena_results.arn,
#           "${aws_s3_bucket.athena_results.arn}/*"
#         ],
#         Principal = {
#           Service = "quicksight.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
