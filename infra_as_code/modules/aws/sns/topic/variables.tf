variable "ENV" {
}

variable "SETTINGS" {
  type = map(string)
}

variable "CUSTOM_POLICY" {
  default = {}
}

variable "PROJECT" {
}

variable "APP" {
}

variable "SNS_TOPIC_ALARM" {
  type = list(string)
}

variable "AWS_TAGS" {
  type = map(string)
}

variable "TREAT_MISSING_DATA"{
  type = string
  default = "active"
}