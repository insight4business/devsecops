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
}

module "cloudtrail" {
  source = "../.."

  trail_name         = "contoso-management-events"
  log_bucket_name    = "contoso-cloudtrail-logs-example"
  log_retention_days = 365

  tags = {
    Project     = "contoso-platform"
    Environment = "shared"
    ManagedBy   = "terraform"
    Owner       = "security@example.com"
  }
}

output "trail_arn" {
  value = module.cloudtrail.trail_arn
}
