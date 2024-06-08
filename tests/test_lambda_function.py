import pytest
from index import lambda_handler

def test_lambda_handler_error_handling():
    # Simulate an error condition by providing a non-existent table name
    event = {}
    context = {}

    # Call the Lambda function
    response = lambda_handler(event, context)

    # Assert the status code
    assert response['statusCode'] == 500

    # Assert the presence of error message in the response body
    assert 'errorMessage' in response['body']
