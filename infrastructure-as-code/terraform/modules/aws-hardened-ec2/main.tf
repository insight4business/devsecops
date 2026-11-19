# Hardened EC2 instance.
# - No SSH key pair and no inbound rule: administration is via SSM Session Manager.
# - IMDSv2 required (token-based metadata, hop limit 1).
# - Encrypted root volume (gp3).
# - AMI resolved from an SSM parameter; later AMI releases do not force replacement.

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

# --- IAM: instance profile with only the SSM agent permissions -----------------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ec2"
  role = aws_iam_role.this.name
  tags = var.tags
}

data "aws_partition" "current" {}

# --- Network: security group with NO ingress rule -------------------------------
resource "aws_security_group" "this" {
  name        = "${var.name}-ec2"
  description = "No inbound access. Outbound HTTPS only."
  vpc_id      = data.aws_subnet.this.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-ec2" })

  # Rules are managed as separate resources; inline rules would fight them.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  for_each = toset(var.egress_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "HTTPS outbound (SSM, package repositories)"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
  tags              = var.tags
}

# --- Instance ---------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                         = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = true
  ebs_optimized               = true

  # key_name is intentionally not set: no SSH key pair.

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    delete_on_termination = true
    tags                  = var.tags
  }

  tags        = merge(var.tags, { Name = var.name })
  volume_tags = var.tags

  lifecycle {
    # The SSM parameter moves when a new AMI is published. Ignoring it avoids
    # surprise replacement; patch in place or replace on purpose with
    # `terraform apply -replace=<address>`.
    ignore_changes = [ami]
  }
}
