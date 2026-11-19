terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "contoso-app"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "platform@example.com"
    }
  }
}

module "private_bucket" {
  source = "../.."

  bucket_name                        = "contoso-app-data-dev-example"
  noncurrent_version_expiration_days = 30
  transition_to_ia_days              = 60
}

output "bucket_arn" {
  value = module.private_bucket.bucket_arn
}
