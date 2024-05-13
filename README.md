# sentiment-analysis-system




## Twitter Fake API
Dataset: https://www.kaggle.com/datasets/kazanova/sentiment140

## S3 buckets structure

raw data bucket
```
    bucket/
        - customer_1
            - raw_tweet_batch_1
            ...
            - raw_tweet_batch_N
        ...
        - customer_M
            ...
```

predicted data bucket
```
    bucket/
        - customer_1
            - predictions_1
            ...
            - predictions_N
        ...
        - customer_M
            ...
```

## Model

Requirements: 
- Have an instance with at least 8GB of memory
- Have python installed
- requirements.txt installed


