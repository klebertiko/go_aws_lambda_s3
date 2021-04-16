##### SQS ALARM #####

resource "aws_cloudwatch_metric_alarm" "messages_received" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSQSNumberOfMessagesReceived"
  comparison_operator = var.SETTINGS["monitoring_mode"] == "passive" ? "GreaterThanOrEqualToThreshold" : "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  alarm_description   = "O número de mensagens retornadas por chamadas para a ação ReceiveMessage está ${var.SETTINGS["monitoring_mode"] == "passive" ? "ACIMA" : "ABAIXO"} do esperado"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "3"
  treat_missing_data  = var.SETTINGS["treat_missing_data"] == "active" ? "breaching" : "missing"
  threshold           = var.SETTINGS["monitoring_mode"] == "passive" ? var.SETTINGS_THRESHOLD["alarm_messages_received_dlq_threshold"] : var.SETTINGS_THRESHOLD["alarm_messages_received_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "messages_sent" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSQSNumberOfMessagesSent"
  comparison_operator = var.SETTINGS["monitoring_mode"] == "passive" ? "GreaterThanOrEqualToThreshold" : "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "NumberOfMessagesSent"
  namespace           = "AWS/SQS"
  alarm_description   = "O número de mensagens adicionadas a uma fila está ${var.SETTINGS["monitoring_mode"] == "passive" ? "ACIMA" : "ABAIXO"} do esperado"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "3"
  treat_missing_data  = var.SETTINGS["treat_missing_data"] == "active" ? "breaching" : "missing"
  threshold           = var.SETTINGS["monitoring_mode"] == "passive" ? var.SETTINGS_THRESHOLD["alarm_messages_sent_dlq_threshold"] : var.SETTINGS_THRESHOLD["alarm_messages_sent_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "oldest_message" {
  alarm_name          = "${var.RESOURCE_PREFIX}-alarmSQSApproximateAgeOfOldestMessage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  alarm_description   = "A idade aproximada de mensagem não excluída mais velha na fila está ACIMA do esperado !"
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  datapoints_to_alarm = "3"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_oldest_message_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

##### SQS DLQ ALARM #####

resource "aws_cloudwatch_metric_alarm" "dlq_messages_received" {
  count               = var.SETTINGS["sqs_enable_dlq"] == "true" ? 1 : 0
  alarm_name          = "${var.SETTINGS["sqs_name_dlq"]}-alarmSQSNumberOfMessagesReceived"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  alarm_description   = "O número de mensagens retornadas por chamadas para a ação ReceiveMessage está ACIMA do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "1"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_messages_received_dlq_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name_dlq"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages_sent" {
  count               = var.SETTINGS["sqs_enable_dlq"] == "true" ? 1 : 0
  alarm_name          = "${var.SETTINGS["sqs_name_dlq"]}-alarmSQSNumberOfMessagesSent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesSent"
  namespace           = "AWS/SQS"
  alarm_description   = "O número de mensagens adicionadas a uma fila está ACIMA do esperado !"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "1"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_messages_sent_dlq_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name_dlq"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}

resource "aws_cloudwatch_metric_alarm" "dlq_oldest_message" {
  count               = var.SETTINGS["sqs_enable_dlq"] == "true" ? 1 : 0
  alarm_name          = "${var.SETTINGS["sqs_name_dlq"]}-alarmSQSApproximateAgeOfOldestMessage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  alarm_description   = "A idade aproximada de mensagem não excluída mais velha na fila está ACIMA do esperado !"
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  datapoints_to_alarm = "3"
  treat_missing_data  = "missing"
  threshold           = var.SETTINGS_THRESHOLD["alarm_oldest_message_dlq_threshold"]
  dimensions = {
    QueueName = var.SETTINGS["sqs_name_dlq"]
  }
  alarm_actions             = var.SETTINGS_ACTIONS["alarm_actions"]
  ok_actions                = var.SETTINGS_ACTIONS["ok_actions"]
  insufficient_data_actions = var.SETTINGS_ACTIONS["insufficient_data_actions"]
  tags                      = var.AWS_TAGS
}