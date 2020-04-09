resource "azurerm_virtual_network" "kafka_poc_vnet" {
  name                = "kafka-poc-vnet"
  location            = azurerm_resource_group.kafka_poc_rg.location
  resource_group_name = azurerm_resource_group.kafka_poc_rg.name
  address_space       = ["10.241.0.0/16"]
}

resource "azurerm_subnet" "kafka_poc_subnet" {
  name                      = "kafka-poc-subnet"
  resource_group_name       = azurerm_resource_group.kafka_poc_rg.name
  address_prefix            = "10.241.0.0/20"
  virtual_network_name      = azurerm_virtual_network.kafka_poc_vnet.name
}