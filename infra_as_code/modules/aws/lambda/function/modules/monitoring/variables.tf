variable "RESOURCE_PREFIX" {}

variable "SETTINGS" {
  type = map(string)
}

variable "SETTINGS_THRESHOLD" {
  type = map(string)

  default = {
    alarm_error_threshold       = "1"
    alarm_invocations_threshold = "0"
  }
}

variable "SETTINGS_ACTIONS" {
  type = map(list(string))

  default = {
    alarm_actions             = []
    ok_actions                = []
    insufficient_data_actions = []
  }
}

variable "AWS_TAGS" {}