import json
import os

import boto3


def create_directory_and_upload_file(bucket_name, dir_path, file_path):
    # Create a new S3 client
    s3 = boto3.client('s3')
    with open(file_path) as f:
        json_data = json.load(f)

    s3.put_object(
        Bucket=bucket_name,
        Key=f"{dir_path}{os.path.basename(file_path)}",
        Body=(bytes(json.dumps(json_data).encode('latin-1'))),
        ContentType='application/json',
    )

    print(f"File '{file_path}' uploaded to directory '{dir_path}' in bucket '{bucket_name}'")


if __name__ == '__main__':
    # create directory structure in both buckets
    # add data (only one customer))
    create_directory_and_upload_file('ccbda-raw-tweets-bucket', 'customer_1/' ,'./data/raw_1k.json')
