terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  # GitHub Actions already authenticated Azure CLI
  use_cli = true
}

# -----------------------------
# Resource Group
# -----------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Project     = "Azure-resources-deployment"
  }
}

# -----------------------------
# Virtual Network
# -----------------------------

resource "azurerm_virtual_network" "main" {
  name                = "${var.vm_name}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = ["10.10.0.0/16"]

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Subnet
# -----------------------------

resource "azurerm_subnet" "main" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["10.10.1.0/24"]
}

# -----------------------------
# Network Security Group
# -----------------------------

resource "azurerm_network_security_group" "main" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Public IP
# -----------------------------

resource "azurerm_public_ip" "main" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# Network Interface
# -----------------------------

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------
# NSG Association
# -----------------------------

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# -----------------------------
# Ubuntu 24.04 VM
# -----------------------------

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  size = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    OS          = "Ubuntu 24.04"
  }
}
