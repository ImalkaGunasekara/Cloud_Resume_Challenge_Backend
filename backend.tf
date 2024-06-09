terraform {
  backend "s3" {
    bucket         = "remote-s3-backend-for-terraform"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "your-dynamodb-table"  # Optional for state locking
  }
}
