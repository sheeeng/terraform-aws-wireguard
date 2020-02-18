resource "aws_eip" "wireguard" {
  vpc = true
  tags = {
    Name = "wireguard"
  }
}

module "wireguard" {
  source               = "git@github.com:sheeeng/terraform-aws-wireguard.git?ref=chore/review"
  ssh_key_id           = "ssh-key-id-0987654"
  vpc_id               = "vpc-01234567"
  subnet_ids           = ["subnet-01234567"]
  eip_id               = "${aws_eip.wireguard.id}"
  wireguard_server_net = "192.168.2.1/24" # client IPs MUST exist in this net
  wireguard_client_public_keys = [
    { "192.168.2.2/32" = "U1t4kAJxdUWWlAqZOknG0m9fJf22T6kpzQJxNYjgpmE=" },   # make sure these are correct
    { "192.168.2.3/32" = "AgjIG8xLfsQdvd+OUxBiVq47Z5JsQkBmYywhHme0ZFc=" },   # wireguard is sensitive
    { "192.168.2.255/32" = "9b9jliJ37/E2spqz2dxHzb79pwaK+Ln8nK3//RGY3kg=" }, # to bad configuration
  ]
}
