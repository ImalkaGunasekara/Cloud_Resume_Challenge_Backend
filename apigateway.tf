# Create the API

resource "aws_api_gateway_rest_api" "cloud-resume-tf" {
  name = "cloud-resume-tf"
  endpoint_configuration {
    types = ["REGIONAL"] # Because by default this is set to EDGE. (other option is 'PRIVATE')
  }
}

# Now for the API, we have to create a resource. (these are like PATHS)
# You can straight away create the method for the root resource (/), but it is good to go with this way.
# Create the resource

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  parent_id   = aws_api_gateway_rest_api.cloud-resume-tf.root_resource_id # This is like the parent path
  path_part   = "example"                                                 # This will create a path /example (This is like sub path where '/' is the parent path)
}

# Now let's create the Method for the resource

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE" # means that the method does not require any authorization; anyone who has access to the API endpoint can invoke the method without providing any credentials or tokens.
}

# Now we have to integrate the Lambda function with the created Method
# Integration with Lambda function

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  type                    = "AWS"  # This could also be ""AWS_PROXY"
  integration_http_method = "POST" # In the context of integrating AWS API Gateway with AWS Lambda, the integration_http_method must be set to POST even if the API method itself uses a different HTTP method (like GET, PUT, DELETE, etc.). This is because the integration type AWS_PROXY uses the POST method to invoke the Lambda function.
  uri                     = aws_lambda_function.cloud-resume-tf.invoke_arn
}

# Now we have to give the API Gateway the permission to invoke the Lambda function
# Permission to invoke Lambda function

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloud-resume-tf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cloud-resume-tf.execution_arn}/*/*" #-->  This grants permissions for all resources and all HTTP methods under the API Gateway.
  # source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.cloud-resume-tf.id}/*/${aws_api_gateway_method.example_method.http_method}${aws_api_gateway_resource.example_resource.path}"

  # The above form constructs the ARN manually using the individual components (aws_api_gateway_rest_api, aws_api_gateway_method, and aws_api_gateway_resource) to specify a more granular permission. It includes specific HTTP methods and resource paths.
}

######################################################################################################################
# Method response
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true # This part is here because we are also allowing CORS at the bottom. Otherwise this part is not needed, if CORS are not getting enabled.
  }
}

# Integration response
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'" # This part is here because we are also allowing CORS at the bottom. Otherwise this part is not needed, if CORS are not getting enabled. 
    # You can change  the origins that you allow for CORS (like specific domain names).
  }

  depends_on = [
    aws_api_gateway_integration.example_integration # This is important
  ]
}

# Here's why each is necessary:

# Method Response: This configuration defines the expected responses for each HTTP status code that your API might return. It specifies the status codes that your API method can produce and optionally the headers for each status code. It essentially tells API Gateway how to respond to requests before integrating with the backend.

# Integration Response: Once API Gateway receives a response from your backend service, the integration response configuration dictates how that response should be transformed before being sent back to the client. This includes mapping backend response headers/body to HTTP response headers/body, applying response transformations, and handling errors.

# Both configurations are crucial for ensuring your API Gateway setup handles requests and responses correctly. The method response defines what the API is capable of returning, and the integration response defines how to process the actual responses from the backend service before sending them back to the client.


# If you are using the console, these things  do not have to be defined, but in here you have to do it.

# Another important thing is that, make sure to have the return statement in your Lambda function with a status code of '200'
###############################################################################################################################



######################################################################################################################

# CORS setup
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Origin" = true
  }

  request_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_templates = {
    "application/json" = ""
  }
}

######################################################################################################################

# Now let's deploy the API
# Deployment
resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cloud-resume-tf.id
  stage_name  = "dev"

  depends_on = [
    aws_api_gateway_integration.example_integration,
    aws_api_gateway_method_response.response_200,
    aws_api_gateway_integration_response.MyDemoIntegrationResponse,
    aws_api_gateway_method.options,
    aws_api_gateway_integration.options,
    aws_api_gateway_method_response.options_200,
    aws_api_gateway_integration_response.options_200
  ]

  # Below one will make sure that any changes mad to the API config will also rflect on the deployed URL as well
  # So auto redeployement will be done
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.cloud-resume-tf.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


# If you want, you can create a deplyement stage like "dev2" or "prod" for later use as well. (not deploying into it, just creating a stage)
