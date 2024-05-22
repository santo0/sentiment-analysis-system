import boto3
import logging
import json

# setup logging
logging.basicConfig(level=logging.INFO)


# lambda handler for calling another lambda function, getting its output and pushing it to kinesis
def lambda_handler(event, context):
    # call another lambda function
    client = boto3.client('lambda')
    response = client.invoke(
        FunctionName='tweeter_api_lambda',
        InvocationType='RequestResponse',
        LogType='Tail'
    )
    # the output of the lambda function is a json object, only read the tweets field
    output = response['Payload'].read()
    logging.info(output)

    output = json.loads(output)
    tweets = output['tweets']


    # push the output to kinesis
    # kinesis only accepts bytes as data, so convert the json object to bytes
    tweets = [json.dumps(tweet).encode('utf-8') for tweet in tweets]
    logging.info(tweets)
    kinesis_client = boto3.client('kinesis')
    for tweet in tweets:
        response = kinesis_client.put_record(
            StreamName='tweet_ingestion_stream',
            Data=tweet,
            PartitionKey='data_ingestion'
        )
        print(response)
    return {
        'statusCode': 200,
        'body': tweets,
    }


if __name__ == '__main__':
    lambda_handler('','')
