terraform {
  backend "s3" {
    bucket = "tyio-terraform"
    key    = "personal-website.tfstate"
    region = "ap-southeast-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.24"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "website" {
  bucket = "tzeyang.ng"
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_s3.json
}

data "aws_iam_policy_document" "public_s3" {
  statement {
    sid = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    effect = "Allow"
    resources = ["${aws_s3_bucket.website.arn}/*"]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  bucket                = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}
