module "storage" {
    source = "./modules/common"
}

module "data_analytics" {
    source = "./modules/data_analytics"
    data_analytics_output_bucket_name = "ccbda-analytics-output-bucket"
}

module "data_ingestion" {
    source = "./modules/data_prediction"
}

module "data_prediction" {
    source = "./modules/data_prediction"
}