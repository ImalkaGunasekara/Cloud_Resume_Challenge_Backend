# For the Lambda function to work correctly it needs to have some mandatory policies to it
# So let's first create a role for this Lambda function

# Create an IAM role for the Lambda function (inside there one of the policies and that is the 'assume role policy' is also included)

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  # Any role that you create using Terraform should have this assume_role_policy attribute.
  # It is going to specify what kind of service that you are creating this role for (in this case, it is a Lambda function. As an example, it could also be EC2, S3)
  # Terraform's "jsonencode" function converts Terraform expression result to valid JSON syntax.

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
# This attaches the AWSLambdaBasicExecutionRole policy to the role, which grants the Lambda function basic permissions to write logs to CloudWatch.

resource "aws_iam_role_policy_attachment" "CloudWatch_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Now let's create a policy that would give Lambda function the permission to get into the DynamoDB table

# data "aws_dynamodb_table" "example" {
#   name = "cloud-resume-tf"
# }

#Above one is due to --> This configuration will ensure that the IAM policy's Resource attribute always reflects the ARN of the DynamoDB table "cloud-resume-tf".
# If the table is recreated or its ARN changes for any reason, Terraform will automatically update the IAM policy to reflect the new ARN.

resource "aws_iam_policy" "DynamoDB_access_policy" {
  name        = "DynamoDB_AccessPolicy"
  description = "A policy to access DynamoDB table"
  # policy      = file("dynamoDB_policy.json")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "VisualEditor0" # Sid is optional and can be used to uniquely identify individual statements within a policy.
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.cloud-resume-tf.arn
      },
    ]
  })
}

# Attach this policy to the role as well

resource "aws_iam_role_policy_attachment" "DynamoDB_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.DynamoDB_access_policy.arn
}

# Befor creating the Lambda function, we have to zip our Lambda function's code file. 
# So when we run terraform apply, it will automatically zip our index.py file to a zip file

# Another thing --> # If the file is not in the current working directory you will need to include a
# path.module in the filename.
# Eg --> source_dir = "${path.module}/folder_name/"
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function.zip"
}


# Now let's create the Lambda function

resource "aws_lambda_function" "cloud-resume-tf" {
  function_name = "cloud-resume-tf"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.lambda_handler" # This says to go to the 'index.py' file and look for the function called 'lambda_handler' in it
  # Because of that makesure to name your Python file as 'index.py'
  runtime = "python3.12" # Specify the runtime

  filename = "lambda_function.zip" # What file to use as the code for the Lambda function, so zip your index.py file and rename it as 'lambda_function.zip'

  source_code_hash = data.archive_file.lambda.output_base64sha256 # This calculates a sha256 hash value with the base of 64 that would keep track of the code changes.


  # Envronement varibales are used to give some configuration parameters securely, like database strings etc. In this case it is not a must. But let's just leave it.
  environment {
    variables = {
      foo = "bar"
    }
  }
}






