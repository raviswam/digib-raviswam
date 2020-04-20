provider "aws" {
  region = "ap-southeast-1"
  access_key = "AKIAR6LOSM5BQO6TMZGU"
  secret_key = "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"  
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tfstate-digib"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "training_app_digib" {
  bucket = "app-digib"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
