from transformers import pipeline
import pandas as pd
import json
import datetime


## Output bucket in S3
s3_bucket = "s3://gold-upc-ccbda-project-data-sentiment-analysis-data/gold_data/"

## declare model from transformers
clf = pipeline("text-classification",model='bhadresh-savani/distilbert-base-uncased-emotion', return_all_scores=True)

## Output bucket in S3
s3_bucket = "s3://gold-upc-ccbda-project-data-sentiment-analysis-data/gold_data/"


## Open file of data - Generally would be from s3 but let's do it now from the githuib demo files
with open('data/latest_1k.json', 'r') as f:
    data = json.load(f)

## Convert to pandas dataframe 
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

## Concat with original file - this will ease its use
df_output = pd.concat([df, df_answers], axis=1)

## Export to s3 bucket where glue will connect
df_output.to_parquet(f"{s3_bucket}{datetime.datetime.now().strftime('%Y%m%d%H%M%s%S')}.parquet")