##### LAMBDA LOG  #####

resource "aws_cloudwatch_log_group" "log_for_lambda" {
  name              = "/aws/lambda/${var.SETTINGS["lambda_function_name"]}"
  retention_in_days = 30
  tags              = var.AWS_TAGS
}

##### LAMBDA ALARM #####

resource "aws_cloudwatch_metric_alarm" "alarm_error" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmLambdaErrors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  alarm_description   = "O número de erros de execução do AWS Lambda está ACIMA do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "1"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_error_threshold"]
  dimensions = {
    FunctionName = var.SETTINGS["lambda_function_name"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "alarm_invocations" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmLambdaInvocations"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  alarm_description   = "O número de execuções do AWS Lambda está ABAIXO do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "3"
  treat_missing_data  = var.SETTINGS["treat_missing_data"] == "active" ? "breaching" : "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_invocations_threshold"]
  dimensions = {
    FunctionName = var.SETTINGS["lambda_function_name"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}