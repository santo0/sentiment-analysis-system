resource "aws_kinesis_stream" "tweet_ingestion_stream" {
  name        = "tweet_ingestion_stream"
  shard_count = 1
}

# customerN.productM<.featureK>
resource "aws_dynamodb_table" "customer1_what" {
  name         = "customer1.what"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tweet_id"
  range_key    = "creation_date"
  attribute {
    name = "tweet_id"
    type = "N"
  }

  attribute {
    name = "creation_date"
    type = "S"
  }
}
resource "aws_dynamodb_table" "customer1_what_and" {
  name         = "customer1.what.and"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tweet_id"
  range_key    = "creation_date"
  attribute {
    name = "tweet_id"
    type = "N"
  }

  attribute {
    name = "creation_date"
    type = "S"
  }
}
resource "aws_dynamodb_table" "customer1_why" {
  name         = "customer1.why"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tweet_id"
  range_key    = "creation_date"
  attribute {
    name = "tweet_id"
    type = "N"
  }

  attribute {
    name = "creation_date"
    type = "S"
  }
}
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "archive_file" "mock_api_zip" {
  type        = "zip"
  source_file = "../ingestion_pipeline/mock_twitter_api/stateless_tweet_retriever.py"
  output_path = "./files/mock_api.zip"
}

data "archive_file" "kinesis_producer_zip" {
  type        = "zip"
  source_file = "../ingestion_pipeline/kinesis_producer/kinesis_producer.py"
  output_path = "./files/producer.zip"
}
data "archive_file" "customer_1_filter_zip" {
  type        = "zip"
  source_file = "../ingestion_pipeline/customer_filter/customer_1/kinesis_consumer.py"
  output_path = "./files/consumer_customer_1.zip"
}
data "archive_file" "batch_loader_customer_1_zip" {
  type        = "zip"
  source_file = "../ingestion_pipeline/batch_loader/customer_1/table_consumer.py"
  output_path = "./files/batch_customer_1.zip"
}

resource "aws_lambda_function" "tweeter_api_lambda" {
  function_name    = "tweeter_api_lambda"
  runtime          = "python3.8"
  handler          = "stateless_tweet_retriever.lambda_handler"
  filename         = data.archive_file.mock_api_zip.output_path
  source_code_hash = data.archive_file.mock_api_zip.output_base64sha256
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 600
  memory_size      = 512
}

resource "aws_lambda_function" "kinesis_producer" {
  function_name    = "kinesis_producer"
  runtime          = "python3.8"
  handler          = "kinesis_producer.lambda_handler"
  filename         = data.archive_file.kinesis_producer_zip.output_path
  source_code_hash = data.archive_file.kinesis_producer_zip.output_base64sha256
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 600
  memory_size      = 512
}

resource "aws_lambda_function" "kinesis_consumer_1" {
  function_name    = "kinesis_consumer_1"
  runtime          = "python3.8"
  handler          = "kinesis_consumer.lambda_handler"
  filename         = data.archive_file.customer_1_filter_zip.output_path
  source_code_hash = data.archive_file.customer_1_filter_zip.output_base64sha256
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 600
  memory_size      = 512
}

resource "aws_scheduler_schedule" "kinesis_producer_cron" {
  name = "producer_scheduler"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(*/1 * * * ? *)" # run every 1 minute

  target {
    arn      = aws_lambda_function.kinesis_producer.arn
    role_arn = data.aws_iam_role.lab_role.arn
  }
}


resource "aws_lambda_event_source_mapping" "consumer_kinesis_event_source_mapping" {
  event_source_arn  = aws_kinesis_stream.tweet_ingestion_stream.arn
  function_name     = aws_lambda_function.kinesis_consumer_1.arn
  starting_position = "LATEST"
  batch_size        = 5
}


# TODO: just use one file.zip for all lambda functions
resource "aws_lambda_function" "table_consumer_1" {
  function_name    = "table_consumer_1"
  runtime          = "python3.8"
  handler          = "table_consumer.lambda_handler"
  filename         = data.archive_file.batch_loader_customer_1_zip.output_path
  source_code_hash = data.archive_file.batch_loader_customer_1_zip.output_base64sha256
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 600
  memory_size      = 512
}


resource "aws_scheduler_schedule" "batch_1_cron" {
  name = "batch_1_scheduler"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(*/1 * * * ? *)" # run every 1 minute

  target {
    arn      = aws_lambda_function.table_consumer_1.arn
    role_arn = data.aws_iam_role.lab_role.arn
  }
}
