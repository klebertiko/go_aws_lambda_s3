data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_region" "current_replica" {
  provider = aws.region_replica
}

locals {
  BUCKET_NAME             = "${var.PROJECT}-${var.ENV}-${var.SETTINGS["name_suffix"]}"
  BUCKET_REPLICA_NAME     = "${var.PROJECT}-${var.ENV}-${var.SETTINGS["name_suffix"]}-replica"
  BUCKET_LOG_NAME         = "${var.PROJECT}-${var.ENV}-${data.aws_region.current.name}-monitoring"
  BUCKET_LOG_REPLICA_NAME = "${var.PROJECT}-${var.ENV}-${data.aws_region.current_replica.name}-monitoring"
}

provider "aws" {
  alias = "region_replica"
}

#### Bucket S3 ####

resource "aws_s3_bucket" "bucket" {
  bucket = local.BUCKET_NAME
  acl    = "private"
  policy = data.aws_iam_policy_document.sec_policy.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = "rotate_versions_object"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 1
    }
  }

  replication_configuration {
    role = aws_iam_role.iam-for-s3-replication.arn

    rules {
      id     = "replicate_all_objects"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.bucket-replication.arn
        storage_class = "STANDARD"
      }
    }
  }

  dynamic "logging" {
    for_each = var.ENABLE_LOGGING == true ? { set = 1 } : {}
    content {
      target_bucket = local.BUCKET_LOG_NAME
      target_prefix = "${local.BUCKET_NAME}/"
    }
  }

  versioning {
    enabled = true
  }

  tags = var.AWS_TAGS
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "sec_policy" {

  statement {
    sid    = "DenyUnsafeTransport"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "*"
    ]
    resources = [
      "arn:aws:s3:::${local.BUCKET_NAME}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.BUCKET_NAME}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms", "AES256"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }

    dynamic "condition" {
      for_each = var.EXCEPT_ENCRYPT_OBJECTS_POLICY
      content {
        test     = "StringNotLike"
        variable = condition.key
        values   = [condition.value]
      }
    }
  }

  dynamic "statement" {
    for_each = var.RESTRICT_ACCESS_CONTACT_LIST
    content {
      sid    = "Restrict access to folders"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = [
        "s3:*"
      ]
      resources = [
        "arn:aws:s3:::${local.BUCKET_NAME}/api/contacts/*"
      ]
      condition {
        test     = "StringNotLike"
        variable = statement.key
        values = [
          for role_id in statement.value :
          role_id
        ]
      }
    }
  }
}

#### Bucket S3 replication ####

resource "aws_s3_bucket" "bucket-replication" {
  provider = aws.region_replica
  bucket   = local.BUCKET_REPLICA_NAME
  acl      = "private"
  policy   = data.aws_iam_policy_document.sec_replica_policy.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = "rotate_versions_object"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 1
    }
  }

  dynamic "logging" {
    for_each = var.ENABLE_LOGGING == true ? { set = 1 } : {}
    content {
      target_bucket = local.BUCKET_LOG_REPLICA_NAME
      target_prefix = "${local.BUCKET_REPLICA_NAME}/"
    }
  }

  versioning {
    enabled = true
  }

  tags = var.AWS_TAGS
}

resource "aws_s3_bucket_public_access_block" "bucket-replication" {
  provider                = aws.region_replica
  bucket                  = aws_s3_bucket.bucket-replication.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "sec_replica_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.current.account_id}"]
    }
    actions = [
      "s3:Get*"
    ]
    resources = [
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/*"
    ]
  }

  statement {
    sid    = "DenyUnsafeTransport"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "*"
    ]
    resources = [
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms", "AES256"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  dynamic "statement" {
    for_each = var.RESTRICT_ACCESS_CONTACT_LIST
    content {
      sid    = "Restrict access to folders"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = [
        "s3:*"
      ]
      resources = [
        "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/api/contacts/*"
      ]
      condition {
        test     = "StringNotLike"
        variable = statement.key
        values = [
          for role_id in statement.value :
          role_id
        ]
      }
    }
  }
}

#### S3 Bucket Role ####

resource "aws_iam_role" "iam-for-s3-replication" {
  name               = "${local.BUCKET_NAME}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.s3_replication_role.json
  tags               = var.AWS_TAGS
}

resource "aws_iam_role_policy" "replication" {
  name   = "${local.BUCKET_NAME}-s3-replication-policy"
  role   = aws_iam_role.iam-for-s3-replication.id
  policy = data.aws_iam_policy_document.s3_replication_policy.json
}

data "aws_iam_policy_document" "s3_replication_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }
    effect = "Allow"
    sid    = ""
  }
}

data "aws_iam_policy_document" "s3_replication_policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${local.BUCKET_NAME}",
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}",
      "arn:aws:s3:::${local.BUCKET_NAME}/*",
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/*"
    ]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${local.BUCKET_NAME}/*",
      "arn:aws:s3:::${local.BUCKET_REPLICA_NAME}/*"
    ]
  }
}