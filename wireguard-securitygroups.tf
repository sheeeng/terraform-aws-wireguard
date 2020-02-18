resource "aws_security_group" "wireguard_security_group_external" {
  name        = "wireguard-${var.env}-external"
  description = "Terraform Managed. Allow Wireguard client traffic from internet."
  vpc_id      = var.vpc_id

  tags = {
    Name       = "wireguard-${var.env}-external"
    Project    = "wireguard"
    tf-managed = "True"
    env        = var.env
  }

  ingress {
    from_port   = var.wireguard_server_port
    to_port     = var.wireguard_server_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wireguard_security_group_administrator" {
  name        = "wireguard-${var.env}-administrator"
  description = "Terraform Managed. Allow admin traffic to internal resources from VPN"
  vpc_id      = var.vpc_id

  tags = {
    Name       = "wireguard-${var.env}-administrator"
    Project    = "vpn"
    tf-managed = "True"
    env        = var.env
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.wireguard_security_group_external.id]
  }

  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = [aws_security_group.wireguard_security_group_external.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
