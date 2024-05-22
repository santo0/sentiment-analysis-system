import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrameCollection
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import StringType
from pyspark.sql.functions import udf
import pytz
import dateutil.parser

TZINFOS = { 'PDT': pytz.timezone('US/Pacific')}

def parse_date_to_iso(date_str):
        try:
            # Define the format and parse the date string
            # dt = datetime.strptime(date_str, '%a %b %d %H:%M:%S %Z %Y')
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
    # df = df.withColumn("date", to_timestamp(df["date"]))        
    df.printSchema()    
    df.show(5)        
    new_dynamic_frame = DynamicFrame.fromDF(df, glueContext, "new_dynamic_frame")    
                                            
    return DynamicFrameCollection({"new_dynamic_frame": new_dynamic_frame}, glueContext)
    
# Sample Glue script to use the transformation        
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
# Script generated for node Amazon S3
AmazonS3_node1716295829914 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://ccbda-custbucket-test/product1/processed"], "recurse": True}, transformation_ctx="AmazonS3_node1716295829914")
# Script generated for node Custom Transformn
CustomTransform_node1716295832723 = MyTransform(glueContext, DynamicFrameCollection({"AmazonS3_node1716295829914": AmazonS3_node1716295829914}, glueContext))
transformed_dynamic_frame = CustomTransform_node1716295832723.select("new_dynamic_frame")
# Script generated for node To Timestamp

ToTimestamp_node1716295836643 = transformed_dynamic_frame.gs_to_timestamp(colName="date", colType="iso")

# Script generated for node AWS Glue Data Catalog
# AWSGlueDataCatalog_node1716295840846 = glueContext.write_dynamic_frame.from_catalog(frame=transformed_dynamic_frame, database="tweetsdb", table_name="cust_test_table_glue", additional_options={"enableUpdateCatalog": True, "updateBehavior": "UPDATE_IN_DATABASE"}, transformation_ctx="AWSGlueDataCatalog_node1716295840846")
AWSGlueDataCatalog_node1716295840846 = glueContext.write_dynamic_frame.from_catalog(frame=ToTimestamp_node1716295836643, database="tweetsdb", table_name="cust_test_table_glue", transformation_ctx="AWSGlueDataCatalog_node1716298249101")
                                                                                  
job.commit()
