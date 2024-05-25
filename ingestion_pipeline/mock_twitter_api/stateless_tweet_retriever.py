import random
import csv
import boto3

dataset_size = 1_600_000

age_weights = {
    (9, 18): 0.2,
    (19, 35): 0.4,
    (36, 50): 0.3,
    (51, 100): 0.1,
}

country_weights = {
    'USA': 0.3,
    'UK': 0.25,
    'Canada': 0.25,
    'Australia': 0.2
}

gender_weights = {
    'Male': 0.45,
    'Female': 0.45,
    'Other': 0.1,
}

def get_random_age():
    # Create a list to store the age categories and their corresponding weights
    age_categories = []
    age_weights_cumulative = []

    # Initialize the cumulative weights
    cumulative_weight = 0

    # Iterate through age_weights to create cumulative weights
    for age_range, weight in age_weights.items():
        age_categories.append(age_range)
        cumulative_weight += weight
        age_weights_cumulative.append(cumulative_weight)
    num_samples = 1
    # Generate random ages based on the given weights
    random_ages = []
    for _ in range(num_samples):
        rand = random.random() * cumulative_weight
        for i, weight in enumerate(age_weights_cumulative):
            if rand < weight:
                random_ages.append(random.randint(*age_categories[i]))
                break

    return random_ages[0]


def get_random_country():
    countries = list(country_weights.keys())
    probabilities = list(country_weights.values())
    random_countries = random.choices(countries, probabilities, k=1)
    return random_countries[0]


def get_random_gender():
    genders = list(gender_weights.keys())
    probabilities = list(gender_weights.values())
    random_genders = random.choices(genders, probabilities, k=1)
    return random_genders[0]


def read_tweets(bucket_name, file_name, offset, limit):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket=bucket_name, Key=file_name)
    data = response['Body'].read().decode('latin-1').splitlines()
    tweets = []
    reader = csv.reader(data)
    for i, row in enumerate(reader):
        if i >= offset and len(tweets) < limit:
            target, ids, date, flag, user, text = row
            tweet = {
                "target": int(target),
                "ids": int(ids),
                "date": date,
                "flag": flag,
                "user": user,
                "text": text,
                "gender": get_random_gender(),
                "age":get_random_age(),
                "country":get_random_country(),
            }
            tweets.append(tweet)
    print(tweets)
    return tweets

def lambda_handler(event, context):
    bucket_name = 'ccbda-system-config-121'
    file_name = f'twitter_dataset/data_{random.randint(1,200)}.csv'
    offset = random.randint(0, 7891)
    limit = random.randint(10, 100)
    tweets = read_tweets(bucket_name, file_name, offset, limit)
    return {
        'tweets': tweets
    }
