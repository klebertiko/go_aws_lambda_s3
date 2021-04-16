locals {
  RESOURCE_PREFIX = "${var.PROJECT}-${var.ENV}-${var.APP}-${var.LAMBDA_SETTINGS["function_name"]}"
}

module "security" {
  source              = "./modules/security"
  RESOURCE_PREFIX     = local.RESOURCE_PREFIX
  AWS_TAGS            = var.AWS_TAGS
  LAMBDA_FIREHOSE_ARN = var.FIREHOSE_ARN
}

module "monitoring" {
  source          = "./modules/monitoring"
  RESOURCE_PREFIX = local.RESOURCE_PREFIX
  SETTINGS = {
    lambda_function_name = aws_lambda_function.lambda.function_name
    treat_missing_data = var.TREAT_MISSING_DATA
  }
  SETTINGS_ACTIONS = {
    alarm_actions             = var.SNS_TOPIC
    ok_actions                = []
    insufficient_data_actions = []
  }
  AWS_TAGS = var.AWS_TAGS
}

module "package" {
  source = "./modules/package"
  SETTINGS = {
    type     = "zip"
    filename = var.LAMBDA_SETTINGS["filename"]
  }
}

module "event_source" {
  source = "./modules/event_source"
  SETTINGS = {
    "event_source_arn" = var.LAMBDA_EVENT_SOURCE["event_source_arn"]
    "event_source_url" = var.LAMBDA_EVENT_SOURCE["event_source_url"]
    "protocol"         = var.LAMBDA_EVENT_SOURCE["protocol"]
    "lambda_arn"       = aws_lambda_function.lambda.arn
  }
}

module "permission" {
  source = "./modules/permission"
  SETTINGS = {
    "lambda_arn" = aws_lambda_function.lambda.arn
    "type_arn"   = var.LAMBDA_INVOKE_FUNCTION["type_arn"]
    "target_arn" = var.LAMBDA_INVOKE_FUNCTION["target_arn"]
  }
}

resource "aws_lambda_function" "lambda" {
  function_name                  = local.RESOURCE_PREFIX
  description                    = var.LAMBDA_SETTINGS["description"]
  handler                        = var.LAMBDA_SETTINGS["handler"]
  runtime                        = var.LAMBDA_SETTINGS["runtime"]
  timeout                        = var.LAMBDA_SETTINGS["timeout"]
  memory_size                    = var.LAMBDA_SETTINGS["memory_size"]
  filename                       = module.package.output_path
  source_code_hash               = module.package.output_base64sha256
  role                           = module.security.role-arn
  kms_key_arn                    = var.KMS_KEY_ARN
  reserved_concurrent_executions = var.LAMBDA_SETTINGS["concurrency_config"]

  vpc_config {
    subnet_ids         = var.VPC_SETTINGS["vpc_subnets"]
    security_group_ids = var.VPC_SETTINGS["security_group_ids"]
  }

  environment {
    variables = var.LAMBDA_VARS
  }

  tracing_config {
    mode = var.LAMBDA_SETTINGS["tracing_config"]
  }

  tags = var.AWS_TAGS
}