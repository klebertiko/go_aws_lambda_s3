variable "ENV" {
}

variable "SETTINGS" {
  type = map(string)
}

variable "PROJECT" {
}

variable "APP" {
}

variable "DLQ_ENABLED" {
  type    = bool
  default = false
}

variable "SNS_TOPIC_ALARM" {
  type = list(string)
}

variable "MONITORING_MODE" {
  type    = string
  default = "active"
}

variable "AWS_TAGS" {
  type = map(string)
}

variable "TREAT_MISSING_DATA"{
  type = string
  default = "active"
}