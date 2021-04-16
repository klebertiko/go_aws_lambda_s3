locals {
  SQS_NAME = "${var.PROJECT}-${var.ENV}-${var.APP}-${var.SETTINGS["name_suffix"]}"
}

data "aws_caller_identity" "current" {}

###### DEFAULT QUEUE #####

module "monitoring" {
  source          = "./modules/monitoring"
  RESOURCE_PREFIX = local.SQS_NAME
  SETTINGS = {
    sqs_name        = aws_sqs_queue.queue.name
    sqs_name_dlq    = var.DLQ_ENABLED == true ? aws_sqs_queue.dlq[0].name : null
    sqs_enable_dlq  = var.DLQ_ENABLED
    monitoring_mode = var.MONITORING_MODE
    treat_missing_data = var.TREAT_MISSING_DATA
  }
  SETTINGS_ACTIONS = {
    alarm_actions             = var.SNS_TOPIC_ALARM
    ok_actions                = []
    insufficient_data_actions = []
  }
  AWS_TAGS = var.AWS_TAGS
}

resource "aws_sqs_queue" "queue" {
  name                       = local.SQS_NAME
  delay_seconds              = var.SETTINGS["delay_seconds"]
  max_message_size           = var.SETTINGS["max_message_size"]
  message_retention_seconds  = var.SETTINGS["message_retention_seconds"]
  receive_wait_time_seconds  = var.SETTINGS["receive_wait_time_seconds"]
  visibility_timeout_seconds = var.SETTINGS["visibility_timeout_seconds"]
  redrive_policy             = var.DLQ_ENABLED == true ? "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dlq[0].arn}\",\"maxReceiveCount\":${var.SETTINGS["dlq_max_receive_count"]}}" : null
  tags                       = var.AWS_TAGS
}

resource "aws_sqs_queue_policy" "policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.queue_policy.json
}

data "aws_iam_policy_document" "queue_policy" {
  policy_id = "${aws_sqs_queue.queue.arn}/SQSDefaultPolicy"

  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage"
    ]

    resources = [
      aws_sqs_queue.queue.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        var.SETTINGS["sns_arn"],
      ]
    }
  }
}

###### IF DLQ QUEUE OPTION IS ENABLED #####

resource "aws_sqs_queue" "dlq" {
  count                      = var.DLQ_ENABLED == true ? 1 : 0
  name                       = "${local.SQS_NAME}-dlq"
  delay_seconds              = var.SETTINGS["delay_seconds"]
  max_message_size           = var.SETTINGS["max_message_size"]
  message_retention_seconds  = var.SETTINGS["message_retention_seconds"]
  receive_wait_time_seconds  = var.SETTINGS["receive_wait_time_seconds"]
  visibility_timeout_seconds = var.SETTINGS["visibility_timeout_seconds"]
  tags                       = var.AWS_TAGS
}

resource "aws_sqs_queue_policy" "dlq_policy" {
  count     = var.DLQ_ENABLED == true ? 1 : 0
  queue_url = aws_sqs_queue.dlq[count.index].id
  policy    = data.aws_iam_policy_document.dlq_queue_policy[count.index].json
}

data "aws_iam_policy_document" "dlq_queue_policy" {
  count = var.DLQ_ENABLED == true ? 1 : 0

  policy_id = "${aws_sqs_queue.dlq[count.index].arn}/SQSDefaultPolicy"

  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage"
    ]

    resources = [
      aws_sqs_queue.dlq[count.index].arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sqs_queue.queue.arn
      ]
    }
  }
}