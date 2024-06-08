resource "aws_dynamodb_table" "cloud-resume-tf" {
  name           = "cloud-resume-tf"
  billing_mode   = "PROVISIONED" # Use PROVISIONED for provisioned capacity mode which falls under the free-tier
  read_capacity  = 5             # Adjust the read capacity units (RCUs) as needed (can have upto 25 in free-tier)
  write_capacity = 5             # Adjust the write capacity units (WCUs) as needed (can have upto 25 in free-tier)
  hash_key       = "id"          # Partition key (main key of the schema)
  #   range_key      = "views" # this is a type of sorting key

  attribute {
    name = "id"
    type = "S" # Assuming "id" is a string attribute
  }

  #   attribute {
  #     name = "views"
  #     type = "N"  # "N" represents the number data type for DynamoDB
  #   }

  #   Even if you define an attribute without it being a hash key or range key, it will say that all attributes have to be indexed wen you 'terraform apply'

  #   global_secondary_index {
  #     name               = "views_index"
  #     hash_key           = "views"
  #     projection_type    = "ALL"  # specifies which attributes from the base table are projected into the index.(currently set to 'ALL')
  #     read_capacity      = 5      # Adjust capacity as needed
  #     write_capacity     = 5      # Adjust capacity as needed
  #   }

  # So just in this time use the console to add the 'views' attribute

  # Adding values to these tables is done either using AWS SDK (Eg: boto3) or console
}

