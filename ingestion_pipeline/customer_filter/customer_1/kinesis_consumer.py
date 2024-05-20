from datetime import datetime
from boto3.dynamodb.conditions import Key
import boto3
import json
import logging
import base64

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
kinesis_client = boto3.client('kinesis', )
dynamodb_client = boto3.client('dynamodb',)
dynamodb_resource = boto3.resource('dynamodb',)

# Define Kinesis stream and DynamoDB table names
stream_name = 'tweet_ingestion_stream'
table_name = 'customerN.productM.featureK'

# Function to read records from Kinesis stream


def read_kinesis_records(event):
    records = event['Records']
    for record in records:
        print(len(records), record)
        # Process each record
        print(process_record(record))


# Function to process individual records and put them into DynamoDB


def process_record(record):
    data = record['data'].decode('latin-1')  # Assuming data is encoded in UTF-8
    print(type(data), data)
    # convert data to json
    tweet_id = str(json.loads(data)['ids'])
    item = {
        'tweet_id': {'N': tweet_id},
        'creation_date': {'S': datetime.utcnow().isoformat()},
        'tweet': {'S': data},
    }
    print(item)

    # Put item into DynamoDB
    dynamodb_client.put_item(TableName=table_name, Item=item)

def lambda_handler(event, context):
    read_kinesis_records(event)
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed records')
    }
