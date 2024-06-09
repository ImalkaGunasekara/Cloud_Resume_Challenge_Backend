terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# provider "aws" {
#   region                   = "us-east-1"
#   shared_credentials_files = ["~/.aws/credentials"]
#   profile                  = "vscode"
# }

provider "aws" {
  region  = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

