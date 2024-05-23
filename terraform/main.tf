module "storage" {
    source = "./modules/common"
    raw_tweets_bucket_name = "ccbda-raw-tweets-bucket-111"
    derived_data_bucket_name = "ccbda-derived-data-bucket-111"
}

module "data_analytics" {
    source = "./modules/data_analytics"
    s3_bucket_name = "ccbda-analytics-output-bucket-111"
    athena_database_name = "tweetsdb"
    athena_table_name = "cust_test_table"
    s3_table_location = "s3://ccbda-analytics-output-bucket-111/product1/processed/"
    # change the iam role to your account one
    iam_role_arn = "arn:aws:iam::211125730795:role/LabRole"
    glue_s3_bucket_name = "aws-glue-assets-bucket-111"
    script_location = "s3://aws-glue-assets-bucket-111/scripts/ParseDateJob.py"
    temporary_directory = "s3://aws-glue-assets-bucket-111/temporary/"
    spark_path = "s3://aws-glue-assets-bucket-111/sparkHistoryLogs/"
}

module "data_ingestion" {
    source = "./modules/data_ingestion"
}

module "data_prediction" {
    source = "./modules/data_prediction"
}