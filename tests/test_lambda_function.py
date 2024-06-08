import json
from unittest.mock import MagicMock, patch
import pytest
from decimal import Decimal

@patch('boto3.resource')
def test_lambda_handler(mock_boto3_resource):
    # Mock DynamoDB resource and table
    mock_table = MagicMock()
    mock_boto3_resource.return_value.Table.return_value = mock_table

    # Mock DynamoDB responses
    mock_table.get_item.return_value = {'Item': {'views': Decimal('0')}}

    # Now import the lambda_handler from index
    from index import lambda_handler

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

if __name__ == '__main__':
    pytest.main()
