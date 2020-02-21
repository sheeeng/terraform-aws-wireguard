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
|`wg_server_net`|`cidr address and netmask`|Yes|The server ip allocation and net - wg_client_public_keys entries MUST be in this netmask range.|
|`wg_client_public_keys`|`list`|Yes|List of maps of client IP/netmasks and public keys. See Usage for details. See Examples for formatting.|
|`wg_server_port`|`integer`|Optional - defaults to `51820`|Port to run wireguard service on, wireguard standard is 51820.|
|`wg_persistent_keepalive`|`integer`|Optional - defaults to `25`|Regularity of Keepalives, useful for NAT stability.|
|`wg_server_private_key_param`|`string`|Optional - defaults to `/wireguard/wg-server-private-key`|The Parameter Store key to use for the VPN server Private Key.|
|`ami_id`|`string`|Optional - defaults to the newest Ubuntu 16.04 AMI|AMI to use for the VPN server.|

## Examples

Please see the following examples to understand usage with the relevant options.

### Simple EIP/public subnet usage

See [examples/simple_eip/main.tf](examples/simple_eip/main.tf) file.

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
