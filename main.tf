data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.bash")

  vars = {
    wireguard_server_private_key = data.aws_ssm_parameter.wireguard_server_private_key.value
    wireguard_server_net         = var.wireguard_server_net
    wireguard_server_port        = var.wireguard_server_port
    peers                        = join("\n", data.template_file.wireguard_client_data_json.*.rendered)
    eip_id                       = var.eip_id
  }
}

data "template_file" "wireguard_client_data_json" {
  template = file("${path.module}/templates/client-data.tpl")
  count    = length(var.wireguard_client_public_keys)

  vars = {
    client_pub_key       = element(values(var.wireguard_client_public_keys[count.index]), 0)
    client_ip            = element(keys(var.wireguard_client_public_keys[count.index]), 0)
    persistent_keepalive = var.wireguard_persistent_keepalive
  }
}

# Use latest Ubuntu image in our nearest region from Canonical (099720109477).
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Modify the security group into a sorted list of strings.
locals {
  wireguard_security_group_external = sort([aws_security_group.wireguard_security_group_external.id])
}

# Clean up and concat the above wireguard default sg with the additional_security_group_ids
locals {
  security_groups_ids = compact(concat(var.additional_security_group_ids, local.wireguard_security_group_external))
}

resource "aws_launch_configuration" "wireguard_launch_configuration" {
  name_prefix                 = "wireguard-${var.env}-"
  image_id                    = var.ami_id == null ? data.aws_ami.ubuntu.id : var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_id
  iam_instance_profile        = (var.eip_id != "disabled" ? aws_iam_instance_profile.wireguard_profile[0].name : null)
  user_data                   = data.template_file.user_data.rendered
  security_groups             = local.security_groups_ids
  associate_public_ip_address = (var.eip_id != "disabled" ? true : false)

  lifecycle {
    create_before_destroy = true
  }
}

<<<<<<< HEAD
resource "aws_autoscaling_group" "wireguard_autoscaling_group" {
  name                 = aws_launch_configuration.wireguard_launch_configuration.name
  launch_configuration = aws_launch_configuration.wireguard_launch_configuration.name
  min_size             = var.autoscaling_group_min_size
  desired_capacity     = var.autoscaling_group_desired_capacity
  max_size             = var.autoscaling_group_max_size
=======
resource "aws_autoscaling_group" "wireguard_asg" {
  name                 = aws_launch_configuration.wireguard_launch_config.name
  launch_configuration = aws_launch_configuration.wireguard_launch_config.name
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
>>>>>>> origin/master
  vpc_zone_identifier  = var.subnet_ids
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
<<<<<<< HEAD
      value               = aws_launch_configuration.wireguard_launch_configuration.name
=======
      value               = aws_launch_configuration.wireguard_launch_config.name
>>>>>>> origin/master
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "wireguard"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "tf-managed"
      value               = "True"
      propagate_at_launch = true
    },
  ]
}
