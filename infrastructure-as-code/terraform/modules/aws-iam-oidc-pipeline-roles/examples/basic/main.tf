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

module "pipeline_roles" {
  source = "../.."

  name_prefix = "contoso-dev"

  # GitHub Actions subjects (exact values, no wildcards).
  plan_subjects  = ["repo:contoso/infra:pull_request"]
  apply_subjects = ["repo:contoso/infra:environment:dev"]

  state_bucket_arn = "arn:aws:s3:::contoso-tfstate-dev-example"

  # Least privilege for what this pipeline deploys: replace with scoped policies.
  apply_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]

  tags = {
    Project     = "contoso-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform@example.com"
  }
}

output "plan_role_arn" {
  value = module.pipeline_roles.plan_role_arn
}

output "apply_role_arn" {
  value = module.pipeline_roles.apply_role_arn
}
