locals {
  TOPIC_NAME = "${var.PROJECT}-${var.ENV}-${var.APP}-${var.SETTINGS["name_suffix"]}"
}

resource "aws_sns_topic" "topic" {
  name = local.TOPIC_NAME
  tags = var.AWS_TAGS
}

resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.topic_policy.json
}

module "monitoring" {
  source          = "./modules/monitoring"
  RESOURCE_PREFIX = local.TOPIC_NAME
  SETTINGS = {
    sns_topic = aws_sns_topic.topic.name
    treat_missing_data = var.TREAT_MISSING_DATA
  }
  SETTINGS_ACTIONS = {
    alarm_actions             = var.SNS_TOPIC_ALARM
    ok_actions                = []
    insufficient_data_actions = []
  }
  AWS_TAGS = var.AWS_TAGS
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.topic.arn,
    ]

    sid = "__default_statement_ID"
  }

  dynamic "statement" {
    for_each = var.CUSTOM_POLICY
    content {
      actions = [
        "SNS:Publish"
      ]

      condition {
        test     = "StringEquals"
        variable = statement.key

        values = [
          for text in statement.value :
          text
        ]
      }

      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      resources = [
        aws_sns_topic.topic.arn,
      ]
    }
  }
}