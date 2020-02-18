output "vpn_security_group_administrator_id" {
  value       = aws_security_group.wireguard_security_group_administrator.id
  description = "The internal Security Group ID to associate with other resources needing to be accessed on VPN."
}

output "vpn_security_group_external_id" {
  value       = aws_security_group.wireguard_security_group_external.id
  description = "The external Security Group ID to associate with the VPN."
}

output "vpn_autoscaling_group_name" {
  value       = aws_autoscaling_group.wireguard_autoscaling_group.name
  description = "The internal Security Group ID to associate with other resources needing to be accessed on VPN."
}
