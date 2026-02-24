terraform {
  backend "s3"{
    bucket = "s3-bucket-backends-99090009"
    key = "prod/terafform.state"
    region = "us-east-1"
    dynamodb_table = "dynamo_db_backends_0000100"
  }
}