data "aws_caller_identity" "current" {}

locals {
  ENVIRONMENT         = terraform.workspace
  AWS_PROVIDER        = var.AWS_PROVIDER[local.ENVIRONMENT]
  AWS_ACCOUNT_ID      = data.aws_caller_identity.current.account_id
}