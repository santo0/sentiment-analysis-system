from transformers import pipeline
import pandas as pd
import json
import boto3

from time import sleep


## declare model from transformers
clf = pipeline("text-classification",model='bhadresh-savani/distilbert-base-uncased-emotion', top_k=None)

## Output bucket in S3
s3_bucket_read = "sentimentanalysisccbda"
s3_bucket_write = "sentimentanalysisccbdaprediction"
s3 = boto3.client('s3')
while True:
    response = s3.list_objects_v2(Bucket=s3_bucket_read)
    if 'Contents' in response:
        for obj in response['Contents']:
            key = obj['Key']
            print(key)
            predict_key = key.replace('raw_tweet_batch', 'processed_results')
            predict_key = predict_key.replace('.json', '.parquet')
            if key.endswith('.json') and 'raw_tweet' in key:
                data = s3.get_object(Bucket=s3_bucket_read, Key=key)
                data = json.loads(data['Body'].read().decode('utf-8'))
                df = pd.json_normalize(data['tweets'])

                ## Let's predict!
                answers = [
                    (clf(row['text'])[0][0]['score'], 
                    clf(row['text'])[0][1]['score'], 
                    clf(row['text'])[0][2]['score'], 
                    clf(row['text'])[0][3]['score'], 
                    clf(row['text'])[0][4]['score'], 
                    clf(row['text'])[0][5]['score'])
                    for _, row in df.iterrows()]

                ## We convert to dataframe and add the proper labelling
                df_answers = pd.DataFrame(answers)
                df_answers.columns = ['sadness', 'joy', 'love', 'anger', 'fear', 'surprise']
                df_answers['sentiment'] = df_answers.idxmax(axis=1)

                ## Concat with original file - this will ease its use
                df_output = pd.concat([df, df_answers], axis=1)
                print(df_output)
                # convert df to parquet
                df_parquet = df_output.to_parquet()
                # write to s3
                s3.put_object(Bucket=s3_bucket_write, Key=predict_key, Body=df_parquet)
    else:
        print("Bucket is empty or does not exist.")

    print("Checking for content in the s3 10 minutes")
    sleep(600) # sleep for 10 minutes


