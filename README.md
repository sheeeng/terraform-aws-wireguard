# terraform-aws-wireguard

A Terraform module to deploy a WireGuard VPN server on AWS. It can also used to run one or more servers behind a load balancer, for redundancy.

## Prerequisites

- Generate a key pair for your server and client.
- Store the server's private key and client's public key in AWS Systems Manager (SSM), which cloud-init will source and add to WireGuard's configuration.

- [Install](https://www.wireguard.com/install/) the WireGuard tools for your operating system.
- Create a directory to store the key pairs.

  ```bash
  mkdir ${HOME}/.wireguard-keys
  ```

- Generate a key pair for each individual client.

  ```bash
  wg genkey | tee ${HOME}/.wireguard-keys/client-1-privatekey \
    | wg pubkey > ${HOME}/.wireguard-keys/client-1-publickey
  wg genkey | tee ${HOME}/.wireguard-keys/client-2-privatekey \
    | wg pubkey > ${HOME}/.wireguard-keys/client-2-publickey
  wg genkey | tee ${HOME}/.wireguard-keys/client-n-privatekey \
    | wg pubkey > ${HOME}/.wireguard-keys/client-n-publickey
  ```

- Generate a key pair for the server.

  ```bash
  wg genkey | tee ${HOME}/.wireguard-keys/server-privatekey \
    | wg pubkey > ${HOME}/.wireguard-keys/server-publickey
  ```

- Add the server private key to the AWS SSM parameter using the fully qualified name of the parameter that you want to add to the system. In this example, we use `/wireguard/wireguard-server-private-key` as the parameter.

  ```bash
  aws ssm put-parameter \
    --name /wireguard/wireguard-server-private-key \
    --type SecureString \
    --value $(cat ${HOME}/.wireguard-keys/server-privatekey)
  ```

- Verify that the AWS SSM parameter exist after the previous step is executed.

  ```bash
  aws ssm get-parameter \
    --name /wireguard/wireguard-server-private-key
  ```

- Add each client's public key, along with the next available IP address as a `key:value` pair to the `wireguard_client_public_keys` map.

## Variables

| Variable Name | Type | Required |Description |
|---------------|-------------|-------------|-------------|
|`subnet_ids`|`list`|Yes|A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list.|
|`ssh_key_id`|`string`|Yes|A SSH public key ID to add to the VPN instance.|
|`vpc_id`|`string`|Yes|The VPC ID in which Terraform will launch the resources.|
|`env`|`string`|Optional - defaults to `production`|The name of environment for WireGuard. Used to differentiate multiple deployments.|
|`eip_id`|`string`|Optional|The EIP ID to which the VPN server will attach. Useful for avoiding changing IPs.|
|`target_group_arns`|`string`|Optional|The Loadbalancer Target Group to which the vpn server ASG will attach.|
|`associate_public_ip_address`|`boolean`|Optional - defaults to `true`|Whether or not to associate a public ip.|
|`additional_security_group_ids`|`list`|Optional|Used to allow added access to reach the WG servers or allow loadbalancer health checks.|
|`autoscaling_group_min_size`|`integer`|Optional - default to `1`|Number of VPN servers to permit minimum, only makes sense in loadbalanced scenario.|
|`autoscaling_group_desired_capacity`|`integer`|Optional - default to `1`|Number of VPN servers to maintain, only makes sense in loadbalanced scenario.|
|`autoscaling_group_max_size`|`integer`|Optional - default to `1`|Number of VPN servers to permit maximum, only makes sense in loadbalanced scenario.|
|`instance_type`|`string`|Optional - defaults to `t2.micro`|Instance Size of VPN server.|
<<<<<<< HEAD
|`wireguard_server_net`|`cidr address and netmask`|Yes|The server ip allocation and net - wireguard_client_public_keys entries MUST be in this netmask range.|
|`wireguard_client_public_keys`|`list`|Yes|List of maps of client IP/netmasks and public keys. See Usage for details. See Examples for formatting.|
|`wireguard_server_port`|`integer`|Optional - defaults to `51820`|Port to run wireguard service on, wireguard standard is 51820.|
|`wireguard_persistent_keepalive`|`integer`|Optional - defaults to `25`|Regularity of Keepalives, useful for NAT stability.|
|`wireguard_server_private_key_param`|`string`|Optional - defaults to `/wireguard/wireguard-server-private-key`|The Parameter Store key to use for the VPN server Private Key.|
=======
|`wg_server_net`|`cidr address and netmask`|Yes|The server ip allocation and net - wg_client_public_keys entries MUST be in this netmask range.|
|`wg_client_public_keys`|`list`|Yes|List of maps of client IP/netmasks and public keys. See Usage for details. See Examples for formatting.|
|`wg_server_port`|`integer`|Optional - defaults to `51820`|Port to run wireguard service on, wireguard standard is 51820.|
|`wg_persistent_keepalive`|`integer`|Optional - defaults to `25`|Regularity of Keepalives, useful for NAT stability.|
|`wg_server_private_key_param`|`string`|Optional - defaults to `/wireguard/wg-server-private-key`|The Parameter Store key to use for the VPN server Private Key.|
>>>>>>> origin/master
|`ami_id`|`string`|Optional - defaults to the newest Ubuntu 16.04 AMI|AMI to use for the VPN server.|

## Examples

Please see the following examples to understand usage with the relevant options.
<<<<<<< HEAD

### Simple EIP/public subnet usage

```terraform
resource "aws_eip" "wireguard" {
  vpc = true
  tags = {
    Name = "wireguard"
  }
}

module "wireguard" {
  source                = "git@github.com:sheeeng/terraform-aws-wireguard.git?ref=chore/review"
  ssh_key_id            = "ssh-key-id-0987654"
  vpc_id                = "vpc-01234567"
  subnet_ids            = ["subnet-01234567"]
  eip_id                = "${aws_eip.wireguard.id}"
  wireguard_server_net         = "192.168.2.1/24" # client IPs MUST exist in this net
  wireguard_client_public_keys = [
    {"192.168.2.2/32" = "U1t4kAJxdUWWlAqZOknG0m9fJf22T6kpzQJxNYjgpmE="}, # make sure these are correct
    {"192.168.2.3/32" = "AgjIG8xLfsQdvd+OUxBiVq47Z5JsQkBmYywhHme0ZFc="}, # wireguard is sensitive
    {"192.168.2.255/32" = "9b9jliJ37/E2spqz2dxHzb79pwaK+Ln8nK3//RGY3kg="}, # to bad configuration
  ]
}
```

### Complex ELB/private subnet usage

```terraform
module "wireguard" {
  source                        = "git@github.com:jmhale/terraform-wireguard.git"
  ssh_key_id                    = "ssh-key-id-0987654"
  vpc_id                        = "vpc-01234567"
  additional_security_group_ids = [aws_security_group.wireguard_ssh_check.id] # for ssh health checks, see below
  subnet_ids                    = ["subnet-76543210"] # You'll want a NAT gateway on this, but we don't document that.
  target_group_arns             = ["arn:aws:elasticloadbalancing:eu-west-1:123456789:targetgroup/wireguard-production/123456789"]
  autoscaling_group_min_size                  = 1 # a sensible minimum, which is also the default
  autoscaling_group_desired_capacity          = 2 # we want two servers running most of the time
  autoscaling_group_max_size                  = 5 # this cleanly permits us to allow rolling updates, growing and shrinking
  associate_public_ip_address   = false # we don't want eip, we want all our traffic out of a single NAT for whitelisting simplicity
  wireguard_server_net                 = "192.168.2.1/24" # client IPs MUST exist in this net
  wireguard_client_public_keys = [
    {"192.168.2.2/32" = "QFX/DXxUv56mleCJbfYyhN/KnLCrgp7Fq2fyVOk/FWU="}, # make sure these are correct
    {"192.168.2.3/32" = "+IEmKgaapYosHeehKW8MCcU65Tf5e4aXIvXGdcUlI0Q="}, # wireguard is sensitive
    {"192.168.2.4/32" = "WO0tKrpUWlqbl/xWv6riJIXipiMfAEKi51qvHFUU30E="}, # to bad configuration
  ]
}
=======

### Simple EIP/public subnet usage

See [examples/simple_eip/main.tf](examples/simple_eip/main.tf) file.
>>>>>>> origin/master

### Complex ELB/private subnet usage

See [examples/complex_elb/main.tf](examples/complex_elb/main.tf) file.

## Output

| Output Name  | Description |
|--------------|-------------|
|`vpn_autoscaling_group_name`|The name of the wireguard Auto Scaling Group|
|`vpn_security_group_administrator_id`|ID of the internal Security Group to associate with other resources needing to be accessed on VPN.|
|`vpn_security_group_external_id`|ID of the external Security Group to associate with the VPN.|

## Caveats

- I would strongly recommend forking this repo or cloning it locally and change the `source` definition to be something that you control. You really don't want your infra to be at the mercy of my changes.
