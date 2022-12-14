locals {
  environment_prefix = "${var.resource_tags["project"]}${var.resource_tags["environment"]}"
  resource_group = "${local.environment_prefix}-rg"
  stroage_name = "${local.environment_prefix}stg"
  vnet = "${local.environment_prefix}vnet"
  subnet_internal = "${local.environment_prefix}internal"
  nic = "${local.environment_prefix}nic"
  ip_internal = "${local.environment_prefix}ip"
  ip_pub = "${local.environment_prefix}publicip"
  nsg_name = "${local.environment_prefix}nsg"
  # subnet_id = "${local.subnet_internal}.id"
}

# Create a resource groups
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group}" 
  location = var.location
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

resource "azurerm_public_ip" "public_ip_01" {
  name                = "${local.ip_pub}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Dev"
  }
  #depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vnet}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location #"West Europe"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${local.subnet_internal}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = "${local.vnet}"
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    time_sleep.wait_30_seconds,
    azurerm_virtual_network.vnet,
  ]
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.nic}"
  location            = var.location #"West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.ip_internal}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_01.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.nsg_name}"
  location            = var.location #"West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgtonic" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.environment_prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location #"West Europe"
  size                = "Standard_F1"
  admin_username      = "adminuser"
  network_interface_ids =  [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.public_ip_01.ip_address
}