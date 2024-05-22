module "storage" {
    source = "./modules/common"
}

module "data_analytics" {
    source = "./modules/data_analytics"
    s3_bucket_name = "ccbda-analytics-output-bucket"
    athena_database_name = "tweetsdb"
    athena_table_name = "cust_test_table"
    s3_table_location = "s3://ccbda-analytics-output-bucket/product1/processed/"
}

module "data_ingestion" {
    source = "./modules/data_prediction"
}

module "data_prediction" {
    source = "./modules/data_prediction"
}