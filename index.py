import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-tf') # Use your table name here

def lambda_handler(event, context):
    try:
        response = table.get_item(Key={'id': '0'})
        if 'Item' not in response:
            raise ValueError("Item with id '0' not found")

        views = int(response['Item']['views'])  # Convert Decimal to int
        views += 1

        print(views)

        table.put_item(Item={'id': '0', 'views': views})

        return {
            'statusCode': 200,
            'body': {'views': views}
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'errorMessage': str(e)})
        }


# Test comment