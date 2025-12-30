variable "location" {
  default = "Central US"
}

variable "environment" {
  default = "dev"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-demo"
  location = var.location

  tags = {
    environment  = var.environment
    managed_by   = "terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "vm" {
  name                = "pip-vm-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# Connect NSG to NIC
resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Linux VM
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${var.environment}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}
