import json
from unittest.mock import MagicMock, patch
import pytest
from decimal import Decimal

# Mock the boto3.resource call before importing index
with patch('index.boto3') as mock_boto3:
    # Mock DynamoDB resource and table
    mock_dynamodb = MagicMock()
    mock_table = MagicMock()
    mock_dynamodb.resource.return_value.Table.return_value = mock_table
    mock_boto3.resource.return_value = mock_dynamodb

    # Now import the lambda_handler from index
    from index import lambda_handler

def test_lambda_handler():
    # Setup the mock responses
    mock_table.get_item.return_value = {'Item': {'views': Decimal('0')}}

    # Invoke Lambda handler
    event = {}
    context = {}
    response = lambda_handler(event, context)

    # Check the response
    assert response['statusCode'] == 200
    assert response['body']['views'] == 1

    # Check DynamoDB interactions
    mock_table.get_item.assert_called_once_with(Key={'id': '0'})
    mock_table.put_item.assert_called_once_with(Item={'id': '0', 'views': 1})
