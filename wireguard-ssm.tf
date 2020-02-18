data "aws_ssm_parameter" "wireguard_server_private_key" {
  name = var.wireguard_server_private_key_parameter
}
