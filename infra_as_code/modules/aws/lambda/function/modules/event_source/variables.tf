variable "SETTINGS" {
  type = map(string)
  default = {
    "event_source_arn" = ""
    "event_source_url" = ""
    "protocol"         = ""
    "lambda_arn"       = ""
  }
}