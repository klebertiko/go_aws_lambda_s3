data "archive_file" "script" {
  type        = var.SETTINGS["type"]
  source_file = "../${var.SETTINGS["filename"]}"
  output_path = "../${var.SETTINGS["filename"]}.${var.SETTINGS["type"]}"
}