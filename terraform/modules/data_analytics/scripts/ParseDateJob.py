import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrameCollection
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import StringType
from pyspark.sql.functions import udf, to_timestamp
import pytz
import dateutil.parser

TZINFOS = { 'PDT': pytz.timezone('US/Pacific')}

def parse_date_to_iso(date_str):
        try:
            # Define the format and parse the date string
            dt = dateutil.parser.parse(date_str, tzinfos= TZINFOS)
            
            # Convert to UTC and then to ISO format        
            dt_utc = dt.astimezone(pytz.UTC)        
            return dt_utc.isoformat()    
        except Exception as e:        
            return None        


parse_date_to_iso_udf = udf(parse_date_to_iso, StringType())
        

def MyTransform(glueContext, dfc) -> DynamicFrameCollection:
    dynamic_frame = dfc.select(list(dfc.keys())[0])    
    df = dynamic_frame.toDF()        
    df.printSchema()    
    df.show(5)        
    df = df.withColumn("date", parse_date_to_iso_udf(df["date"]))        
    # df.printSchema()    
    # df.show(5)        
    df = df.withColumn("date", to_timestamp(df["date"]))        
    # df.printSchema()    
    # df.show(5)        
    new_dynamic_frame = DynamicFrame.fromDF(df, glueContext, "new_dynamic_frame")    
                                            
    return DynamicFrameCollection({"new_dynamic_frame": new_dynamic_frame}, glueContext)
    
# VARIABLES: SET THEM BASED ON TERRAFORM DEPLOY
s3_bucket_path = "s3://ccbda-analytics-output-bucket-111/product1/processed"
athena_db_name = "tweetsdb"
athena_table_name = "cust_test_table"


# Sample Glue script to use the transformation        
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
# Script generated for node Amazon S3
AmazonS3_node = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": [s3_bucket_path], "recurse": True}, transformation_ctx="write_to_catalog")
# Script generated for node Custom Transformn
CustomTransform_node = MyTransform(glueContext, DynamicFrameCollection({"write_to_catalog": AmazonS3_node}, glueContext))
transformed_dynamic_frame = CustomTransform_node.select("new_dynamic_frame")
# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node = glueContext.write_dynamic_frame.from_catalog(frame=transformed_dynamic_frame, database=athena_db_name, table_name=athena_table_name, transformation_ctx="write_to_catalog")
                                                                                  
job.commit()


