output "resource_group_name" {
  description = "Resource group holding the network."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "VNet ID."
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "Workload subnet ID."
  value       = azurerm_subnet.workload.id
}

output "nsg_id" {
  description = "NSG ID attached to the workload subnet."
  value       = azurerm_network_security_group.workload.id
}

output "nat_public_ip" {
  description = "Outbound public IP when the NAT gateway is enabled, otherwise null."
  value       = var.enable_nat_gateway ? azurerm_public_ip.nat[0].ip_address : null
}
