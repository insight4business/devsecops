# Network baseline: resource group, VNet, one subnet, NSG and optional NAT.
# The NSG has no custom allow rule unless admin_source_cidrs is set. Azure's
# built-in rules (VNet-to-VNet allow, Internet inbound deny) always exist and
# cannot be removed; an explicit deny-all inbound rule is added for clarity.

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.name}-network"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-${var.name}-workload"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_prefix]
}

# --- NSG ---------------------------------------------------------------------------
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-${var.name}-workload"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

# Created only when at least one admin CIDR is provided.
resource "azurerm_network_security_rule" "admin_inbound" {
  count = length(var.admin_source_cidrs) > 0 ? 1 : 0

  name                        = "allow-admin-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = var.admin_ports
  source_address_prefixes     = var.admin_source_cidrs
  destination_address_prefix  = var.subnet_prefix
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# --- Optional NAT gateway (controlled, single outbound address) ---------------------
resource "azurerm_public_ip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "pip-${var.name}-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  name                    = "natgw-${var.name}"
  location                = azurerm_resource_group.this.location
  resource_group_name     = azurerm_resource_group.this.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "workload" {
  count = var.enable_nat_gateway ? 1 : 0

  subnet_id      = azurerm_subnet.workload.id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}
