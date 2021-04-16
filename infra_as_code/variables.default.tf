variable "PROJECT" {
  default = "go_aws_lambda_s3"
}

variable "APP" {
  default = "file_event"
}

variable "AWS_PROVIDER" {
  type = map(map(string))

  default = {
    dev = {
      region                 = "us-east-1"
    }
    hml = {
      region                 = "us-east-1"
    }
    prd = {
      region                 = "us-east-1"
    }
  }
}