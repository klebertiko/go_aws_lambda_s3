variable "ENV" {
}

variable "LAMBDA_SETTINGS" {
  type = any
}

variable "LAMBDA_VARS" {
  type = any
}

variable "LAMBDA_LAYER" {
  type    = list(string)
  default = []
}

variable "LAMBDA_EVENT_SOURCE" {
  type = any
  default = {
    "event_source_arn" = ""
    "event_source_url" = ""
    "protocol"         = ""
  }
}

variable "LAMBDA_INVOKE_FUNCTION" {
  type = any
  default = {
    "type_arn"   = ""
    "target_arn" = ""
  }
}

variable "KMS_KEY_ARN" {
  type    = string
  default = ""
}

variable "VPC_SETTINGS" {
  type = any
  default = {
    "vpc_subnets"        = []
    "security_group_ids" = []
  }
}

variable "PROJECT" {
}

variable "APP" {
}

variable "SNS_TOPIC" {
  type    = list
  default = []
}

variable "AWS_TAGS" {
  type = map(string)
}

variable "FIREHOSE_ARN" {
  default = {}
}

variable "TREAT_MISSING_DATA"{
  type = string
  default = "active"
}