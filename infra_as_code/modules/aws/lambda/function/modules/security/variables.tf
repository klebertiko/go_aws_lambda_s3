variable "RESOURCE_PREFIX" {}

variable "AWS_TAGS" {
  type = map(string)
}
variable "LAMBDA_FIREHOSE_ARN" {
  default = {}
}