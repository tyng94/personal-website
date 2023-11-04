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

resource "aws_s3_bucket" "website" {
  bucket = "tzeyang.ng"
}

resource "aws_route53_zone" "tzeyang_ng" {
  name = "tzeyang.ng"
}