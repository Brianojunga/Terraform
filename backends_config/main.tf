provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "s3_backends_store"{
    bucket = "s3-bucket-backends-99090009"
    tags = {
        Name = "backends_store"
    }
}

resource "aws_dynamodb_table" "backends_store" {
    name = "dynamo_db_backends_0000100"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}

output "s3_backends_bucket" {
  value = aws_s3_bucket.s3_backends_store.bucket
}

output "dynamo_db_lock" {
    value = aws_dynamodb_table.backends_store.name
}