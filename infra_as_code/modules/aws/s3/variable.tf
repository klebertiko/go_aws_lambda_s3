variable "ENV" {
}

variable "SETTINGS" {
  type = map(string)
}

variable "PROJECT" {
}

variable "APP" {
}

variable "AWS_TAGS" {
  type = map(string)
}

variable "EXCEPT_ENCRYPT_OBJECTS_POLICY" {
  default = {}
}

variable "RESTRICT_ACCESS_CONTACT_LIST" {
  default = {}
}

variable "ENABLE_LOGGING" {
  default = false
}