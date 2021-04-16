data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

locals {
  AWS_REGION  = data.aws_region.current_region.name
  AWS_ACCOUNT = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = var.RESOURCE_PREFIX
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
  path               = "/service-role/"
  tags               = var.AWS_TAGS
}

resource "aws_iam_role_policy" "iam_for_lambda_policy" {
  name   = var.RESOURCE_PREFIX
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

data "aws_iam_policy_document" "lambda_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    effect = "Allow"
    sid    = ""
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::iti-data-*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::iti-data-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::aws-athena-query-results-*/*",
      "arn:aws:s3:::aws-athena-query-results-*",
      "arn:aws:s3:::aws-athena-examples*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage",
      "SQS:GetQueueAttributes",
      "SQS:SendMessage",
      "SQS:GetQueueUrl"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:List*",
      "secretsmanager:Describe*",
      "secretsmanager:Get*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${local.AWS_REGION}:${local.AWS_ACCOUNT}:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.AWS_REGION}:${local.AWS_ACCOUNT}:log-group:/aws/lambda/${var.RESOURCE_PREFIX}:*"
    ]
  }
  statement {
    sid    = "GluePermissions"
    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:DeleteDatabase",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:UpdateDatabase",
      "glue:CreateTable",
      "glue:DeleteTable",
      "glue:BatchDeleteTable",
      "glue:UpdateTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:BatchCreatePartition",
      "glue:CreatePartition",
      "glue:DeletePartition",
      "glue:BatchDeletePartition",
      "glue:UpdatePartition",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${local.AWS_REGION}:${local.AWS_ACCOUNT}:table/iti-data-*"
    ]
  }
  dynamic "statement" {
    for_each = var.LAMBDA_FIREHOSE_ARN
    content {
      effect = "Allow"
      actions = [
        "firehose:PutRecord",
        "firehose:PutdRecordBatch",
        "firehose:DescribeDeliveryStream",
        "firehose:ListDeliveryStreams",
        "firehose:ListTagsForDeliveryStream",
        "firehose:CreateDeliveryStream",
        "firehose:TagDeliveryStream",
        "firehose:UpdateDestination"
      ]
      resources =  statement.value
    }
  }
}