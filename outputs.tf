output "DynamoDB_table_ARN" {
  value = aws_dynamodb_table.cloud-resume-tf.arn
}

output "Invoke_URL" {
  value = aws_api_gateway_deployment.example_deployment.invoke_url
}