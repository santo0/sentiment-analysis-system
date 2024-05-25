# module "storage" {
#     source = "./modules/common"
# }


# module "data_ingestion" {
#     source = "./modules/data_ingestion"
# }

# module "data_prediction" {
#     source = "./modules/data_prediction"
# }

# module "data_analytics" {
#     source = "./modules/data_analytics"
#     customer_1_bucket = module.storage.customer_1_bucket
#     athena_database_name = "ccbda_database"
#     athena_table_name = "ccbda_table"
#     s3_table_location = "s3://ccbda-customer-1-bucket-1/what/processed/"
#     glue_s3_bucket_name = "ccbda-glue-assets-bucket"
#     script_location = "s3://ccbda-glue-assets-bucket/scripts/ParseDateJob.py"
#     temporary_directory = "s3://ccbda-glue-assets-bucket/temporary/"
#     spark_path = "s3://ccbda-glue-assets-bucket/sparkHistoryLogs/"
# }