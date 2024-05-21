import boto3
from boto3.dynamodb.conditions import Attr

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')

# Define your table name and the field to remove
table_name = 'customerN.productM.featureK'
field_to_remove = 'batch_date'
primary_key = 'tweet_id'  # Replace with your actual primary key
sort_key = 'creation_date'  # Replace with your actual sort key


# Reference to the DynamoDB table
table = dynamodb.Table(table_name)

# Function to scan the table and get all items


def scan_table():
    response = table.scan(
        FilterExpression=Attr(field_to_remove).exists()
    )
    items = response.get('Items', [])
    while 'LastEvaluatedKey' in response:
        response = table.scan(
            FilterExpression=Attr(field_to_remove).exists(),
            ExclusiveStartKey=response['LastEvaluatedKey']
        )
        items.extend(response.get('Items', []))
    return items

# Function to remove a field from an item


def remove_field_from_item(item):
    key = {primary_key: item[primary_key], sort_key: item[sort_key]}
    update_expression = f"REMOVE {field_to_remove}"
    try:
        table.update_item(
            Key=key,
            UpdateExpression=update_expression
        )
        print(
            f"Removed field '{field_to_remove}' from item with primary key: {key}")
    except Exception as e:
        print(
            f"Error removing field '{field_to_remove}' from item with primary key {key}: {e}")

# Main function to process all items


def main():
    items = scan_table()
    print(f"Found {len(items)} items to update.")
    for item in items:
        remove_field_from_item(item)


if __name__ == '__main__':
    main()
