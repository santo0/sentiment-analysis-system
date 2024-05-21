import boto3
import os
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Get environment variables
table_names = ['customer1.what', 'customer1.what.and', 'customer1.why']
bucket_name = 'ccbda-customer-1-bucket'


def get_items_without_batch_date(table):
    response = table.scan(
        FilterExpression='attribute_not_exists(batch_date)',
    )
    print(response)
    return response['Items']


def process_and_store_items():
    for table_name in table_names:
        table = dynamodb.Table(table_name)
        items = get_items_without_batch_date(table)
        if not items:
            print(f'No items to process for table {table_name}')
            continue
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
        # skip customer name
        batch_path = os.path.join(
            '/'.join(table_name.split('.')[1:]),
            'raw',
            f'batch_{batch_date}.json',
        )
        print(batch_path)
        s3.put_object(
            Bucket=bucket_name,
            Key=batch_path,
            Body=json.dumps(batch_dump)
        )


def lambda_handler(event, context):
    process_and_store_items()
