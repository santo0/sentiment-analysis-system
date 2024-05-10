from transformers import pipeline
import pandas as pd
import json
import datetime

clf = pipeline("text-classification",model='bhadresh-savani/distilbert-base-uncased-emotion', return_all_scores=True)
s3_bucket = "s3://gold-upc-ccbda-project-data-sentiment-analysis-data/gold_data/"

with open('data/latest_1k.json', 'r') as f:
    data = json.load(f)

# data = json.loads(json_data)

df = pd.json_normalize(data['tweets'])

df = df.head(10)

answers = [
    (clf(row['text'])[0][0]['score'], 
    clf(row['text'])[0][1]['score'], 
    clf(row['text'])[0][2]['score'], 
    clf(row['text'])[0][3]['score'], 
    clf(row['text'])[0][4]['score'], 
    clf(row['text'])[0][5]['score'])
    for _, row in df.iterrows()]

df_answers = pd.DataFrame(answers)
df_answers.columns = ['sadness', 'joy', 'love', 'anger', 'fear', 'surprise']

df_output = pd.concat([df, df_answers], axis=1)

df_output.to_parquet(f"{s3_bucket}{datetime.datetime.now().strftime('%Y%m%d%H%M%s%S')}.parquet")