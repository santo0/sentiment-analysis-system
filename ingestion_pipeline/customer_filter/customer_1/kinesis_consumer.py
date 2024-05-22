from datetime import datetime
import boto3
import json
import logging
import base64

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_client = boto3.client('dynamodb',)

# table_name = 'customerN.productM.featureK'
CUSTOMER_NAME = 'customer1'
# table_names = ['customer1.what', 'customer1.what.and', 'customer1.why']
FILTERS = {
    'what': ['and'],
    'why': None,
}


def read_kinesis_records(event):
    records = event['Records']
    for record in records:
        print(len(records), record)
        # Process each record
        print(process_record(record))


def get_tables_to_ingest(text):
    tables_to_ingest = []
    for product, features in FILTERS.items():
        if product in text:
            if features and all(feature in text for feature in features):
                tables_to_ingest.append(
                    f'{CUSTOMER_NAME}.{product}.{features}')
            else:
                tables_to_ingest.append(f'{CUSTOMER_NAME}.{product}')
    return tables_to_ingest


def process_record(record):
    b64_data = record['kinesis']['data']
    decoded_data = base64.b64decode(b64_data).decode('utf-8')
    print(decoded_data)
    # convert data to json
    tweet_md = json.loads(decoded_data)
    tweet_id = str(tweet_md['ids'])
    item = {
        'tweet_id': {'N': tweet_id},
        'creation_date': {'S': datetime.utcnow().isoformat()},
        'tweet': {'S': decoded_data},
    }
    print(item)
    tables_to_ingest = get_tables_to_ingest(tweet_md['text'].lower())
    for table_name in tables_to_ingest:
        dynamodb_client.put_item(TableName=table_name, Item=item)


def lambda_handler(event, context):
    read_kinesis_records(event)
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed records')
    }
