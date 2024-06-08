import pytest
from index import lambda_handler

def test_lambda_handler_error_handling():
    
    response = lambda_handler()

    
    assert response == 4

   