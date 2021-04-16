##### SNS ALARM #####

resource "aws_cloudwatch_metric_alarm" "notifications_failed" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSNSNotificationsFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  alarm_description   = "O número de mensagens que o Amazon SNS falhou ao entregar está ACIMA do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "1"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_error_threshold"]
  dimensions = {
    TopicName = var.SETTINGS["sns_topic"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "notification_delivered" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSNSNotificationDelivered"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "NumberOfNotificationsDelivered"
  namespace           = "AWS/SNS"
  alarm_description   = "O número de mensagens entregues com êxito dos tópicos do Amazon SNS para os terminais de inscrição (Ex: SQS), está ABAIXO do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "3"
  treat_missing_data  = var.SETTINGS["treat_missing_data"] == "active" ? "breaching" : "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_delivered_threshold"]
  dimensions = {
    TopicName = var.SETTINGS["sns_topic"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "messages_published" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSNSMessagesPublished"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "NumberOfMessagesPublished"
  namespace           = "AWS/SNS"
  alarm_description   = "O número de mensagens publicadas nos seus tópicos do Amazon SNS está ABAIXO do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "3"
  treat_missing_data  = var.SETTINGS["treat_missing_data"] == "active" ? "breaching" : "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_published_threshold"]
  dimensions = {
    TopicName = var.SETTINGS["sns_topic"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

