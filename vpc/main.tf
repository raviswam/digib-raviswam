
provider "aws" {
  region = "ap-southeast-1"
  access_key = "AKIAR6LOSM5BQO6TMZGU"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket = "tfstate-digib"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "vpc" {
  source = "../modules/terraform-aws-vpc"

  name = "training-vpc"
  cidr = "${var.cidr}"
  azs                 = "${var.azs}"
  private_subnets     = "${var.private_subnets}"
  public_subnets      = "${var.public_subnets}"
  database_subnets    = "${var.database_subnets}"

  create_database_subnet_group = false
  enable_nat_gateway = true
  enable_vpn_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers

  tags = {
    Owner       = "ECS-DEVTEAM"
    Environment = "${var.env}"
  }
}

# log_group

resource "aws_cloudwatch_log_group" "training-sandbox-loggroup" {
	name = "training-loggroup"
}

# logstream

resource "aws_cloudwatch_log_stream" "logstream" {
  name           = "CloudWatchLogStream"
  log_group_name = aws_cloudwatch_log_group.training-sandbox-loggroup.name
}

# VPC Flow Logs

resource "aws_flow_log" "VPC_flow_log" {
  log_group_name = aws_cloudwatch_log_group.training-sandbox-loggroup.name
  iam_role_arn   = aws_iam_role.flowlog_role.arn
  vpc_id         = module.vpc.vpc_id
  traffic_type   = "ALL"
}

resource "aws_iam_role" "flowlog_role" {
  name = "flowlog_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.flowlog_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Cloud Trail Logs for Mointoring

resource "aws_cloudtrail" "cloudtraillog" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.training.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
}

resource "aws_s3_bucket" "training" {
  bucket        = var.s3-bucket-name
  force_destroy = true

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
            "Resource": "arn:aws:s3:::${var.s3-bucket-name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.s3-bucket-name}/*",
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

resource "aws_route53_zone" "private" {
  name = "digib.raviswam.com"
  vpc {
     vpc_id = module.vpc.vpc_id
  }
}
