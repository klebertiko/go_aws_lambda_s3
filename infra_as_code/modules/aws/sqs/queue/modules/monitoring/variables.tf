variable "RESOURCE_PREFIX" {}

variable "SETTINGS" {
  type = map(string)
}

variable "SETTINGS_THRESHOLD" {
  type = map(string)

  default = {
    alarm_messages_received_threshold     = "0"
    alarm_messages_sent_threshold         = "0"
    alarm_oldest_message_threshold        = "1800"
    alarm_messages_received_dlq_threshold = "1"
    alarm_messages_sent_dlq_threshold     = "1"
    alarm_oldest_message_dlq_threshold    = "1800"
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