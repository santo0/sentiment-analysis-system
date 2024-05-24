import csv
import random

from flask import Flask, jsonify

from rando_generator import (
    get_random_age, 
    get_random_country, 
    get_random_gender,
)
app = Flask(__name__)

file_name = './data/training.1600000.processed.noemoticon.csv'

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


csv_offset = 0
dataset_size = 1_600_000

def read_tweets(file_path, offset, limit):
    tweets = []
    with open(file_path, 'r', encoding='latin-1') as csvfile:
        reader = csv.reader(csvfile)
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
                    "gender": get_random_gender(gender_weights),
                    "age":get_random_age(age_weights),
                    "country":get_random_country(country_weights),
                }
                tweets.append(tweet)
    return tweets


@app.route('/tweets/latest', methods=['GET'])
def latest_tweets():
    global csv_offset, file_name
    limit = random.randint(0, 10)
    tweets = read_tweets(file_name, csv_offset, limit)
    csv_offset = (csv_offset + limit) % dataset_size
    return jsonify({"tweets": tweets})


if __name__ == '__main__':
    app.run(port=5000, debug=True)
