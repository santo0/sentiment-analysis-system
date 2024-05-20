import boto3
import os
import json
from datetime import datetime

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Get environment variables
table_name = 'customerN.productM.featureK'
bucket_name = 'ccbda-raw-tweets-bucket'

# Function to query DynamoDB for items without 'batch_date'


def get_items_without_batch_date(table):
    response = table.scan(
        FilterExpression='attribute_not_exists(batch_date)',
        Limit=5  # Adjust based on your needs and DynamoDB throughput
    )
    print(response)
    return response['Items']

# Function to update items with 'batch_date' and store them in S3


def process_and_store_items():
    table = dynamodb.Table(table_name)
    items = get_items_without_batch_date(table)
    if not items:
        print('No items to process')
        return
    batch_date = datetime.now().isoformat()

    # Update items in DynamoDB
    with table.batch_writer() as batch:
        for item in items:
            item['batch_date'] = batch_date
            batch.put_item(Item=item)
    batch_dump = {'tweets': []}

    for item in items:
        batch_dump['tweets'].append(json.loads(item['tweet']))
    # Store batch in S3
    s3.put_object(
        Bucket=bucket_name,
        Key=f'batch_{batch_date}.json',
        Body=json.dumps(batch_dump)
    )


def lambda_handler(event, context):
    process_and_store_items()


if __name__ == '__main__':
    process_and_store_items()
