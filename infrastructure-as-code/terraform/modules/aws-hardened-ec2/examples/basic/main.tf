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

module "app_server" {
  source = "../.."

  name          = "contoso-app-01"
  subnet_id     = "subnet-0123456789abcdef0" # placeholder: a private subnet
  instance_type = "t3.small"

  # Narrow outbound HTTPS to your VPC endpoint or NAT range when possible.
  egress_cidrs = ["198.51.100.0/24"]

  tags = {
    Project     = "contoso-app"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform@example.com"
  }
}

output "instance_id" {
  value = module.app_server.instance_id
}
