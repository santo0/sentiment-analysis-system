import boto3
from boto3.dynamodb.conditions import Key
from datetime import datetime
import json

# Initialize AWS clients
kinesis_client = boto3.client('kinesis', )
dynamodb_client = boto3.client('dynamodb',)
dynamodb_resource = boto3.resource('dynamodb',)

# Define Kinesis stream and DynamoDB table names
stream_name = 'tweet_ingestion_stream'
table_name = 'customerN.productM.featureK'

# Function to read records from Kinesis stream


def read_kinesis_records():
    shard_id = None
    shard_iterator = kinesis_client.get_shard_iterator(
        StreamName=stream_name,
        ShardId='shardId-000000000000',  # Replace with your actual shard ID
        ShardIteratorType='LATEST'
    )['ShardIterator']
    while True:
        records_response = kinesis_client.get_records(
            ShardIterator=shard_iterator,
            Limit=10
        )

        records = records_response['Records']
        for record in records:
            print(len(records), record)
            # Process each record
            print(process_record(record))

        if 'NextShardIterator' in records_response:
            shard_iterator = records_response['NextShardIterator']
        else:
            break

# Function to process individual records and put them into DynamoDB


def process_record(record):
    data = record['Data'].decode('utf-8')  # Assuming data is encoded in UTF-8
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

# Main function


def main():
    read_kinesis_records()


if __name__ == '__main__':
    main()
