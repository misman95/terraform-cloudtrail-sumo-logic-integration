terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    sumologic = {
      source = "sumologic/sumologic"
      version = "2.13" # set the Sumo Logic Terraform Provider version
    }
  }

  required_version = ">= 0.14.9"
}

provider "sumologic" {
    environment = var.sumo_env_region
    access_id   = var.sumo_env_accessid
    access_key  = var.sumo_env_accesskey
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "aws_caller_identity" "current" {}

## Create CloudTrail
resource "aws_cloudtrail" "trail-sumo" {
  name                          = var.trail_name
  s3_bucket_name                = "${aws_s3_bucket.trail-sumo.id}"
  include_global_service_events = true
  is_multi_region_trail	        = true
}


## Create S3 Bucket
resource "aws_s3_bucket" "trail-sumo" {
  bucket        = var.s3_bucket
  force_destroy = true
}

## Create S3 Bucket Policy
resource "aws_s3_bucket_policy" "trail-sumo" {
  bucket = "${aws_s3_bucket.trail-sumo.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.trail-sumo.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.trail-sumo.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}



data "aws_iam_policy_document" "cloudtrail-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.role_identifiers]
    }

    condition {
      test = "StringEquals"
      values = [var.role_condition]
      variable = "sts:ExternalId"
    }
  }
}


resource "aws_iam_role" "trail-role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail-assume-role-policy.json

  inline_policy {
    name   = "trail-sumo-policy"
    policy = data.aws_iam_policy_document.inline-policy.json
  }

}

data "aws_iam_policy_document" "inline-policy" {
  statement {
    actions = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucketVersions", "s3:ListBucket"]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.trail-sumo.arn}/*", "${aws_s3_bucket.trail-sumo.arn}"
    ]
  }
}



#### Final Step

resource "sumologic_cloudtrail_source" "terraform_cloudtrail_source" {
  name          = "Amazon Cloultrail"
  description   = "My description"
  category      = "aws/logs/cloudtrail"
  content_type  = "AwsCloudTrailBucket"
  scan_interval = 300000
  paused        = false
  collector_id  = "${sumologic_collector.collector.id}"

  authentication {
    type = "AWSRoleBasedAuthentication"
    role_arn = "${aws_iam_role.trail-role.arn}"
  }

  path {
    type = "S3BucketPathExpression"
    bucket_name     = "${aws_s3_bucket.trail-sumo.id}"
    path_expression = "AWSLogs/*"
  }
}

resource "sumologic_collector" "collector" {
  name        = "AWS CloudTrail Collector"
  description = "AWS CloudTrail Collector"
}
