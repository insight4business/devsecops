variable "name" {
  description = "Name of the instance and prefix for related resources."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 characters: letters, digits and hyphens."
  }
}

variable "subnet_id" {
  description = "Private subnet where the instance is placed. The VPC is derived from it."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "ami_ssm_parameter" {
  description = "Public or private SSM parameter holding the AMI ID. Default: latest Amazon Linux 2023 (x86_64)."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "root_volume_size_gb" {
  description = "Root volume size in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb >= 8
    error_message = "root_volume_size_gb must be at least 8."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key for the root volume. Null uses the AWS-managed EBS key (still encrypted)."
  type        = string
  default     = null
}

variable "egress_cidrs" {
  description = "Destinations allowed for outbound HTTPS (443). SSM needs 443 to its endpoints; prefer VPC endpoints and a narrow list."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip" {
  description = "Give the instance a public IP. Keep false: access is through SSM Session Manager."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
