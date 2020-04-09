provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "kafka_poc_rg" {
  name     = var.resource_group
  location = var.azure_region
  tags = {
    cluster = "kafka-poc"
    env = "dev"
  }
}

resource "azurerm_kubernetes_cluster" "kafka_poc_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.kafka_poc_rg.location
  resource_group_name = azurerm_resource_group.kafka_poc_rg.name
  dns_prefix          = var.dns_name
  kubernetes_version  = var.kubernetes_version
  default_node_pool {
    name                  = "kafkapoc"
    vm_size               = "Standard_F4s_v2"
    node_count            = 8
    vnet_subnet_id        = azurerm_subnet.kafka_poc_subnet.id
    enable_auto_scaling   = true
    min_count             = 8
    max_count             = 100
    os_disk_size_gb       = "100"
  }
  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }
  network_profile {
    network_plugin = "kubenet"
  }
  addon_profile {
    kube_dashboard {
      enabled = true
    } 
  }
  role_based_access_control {
    enabled = true
  }
  service_principal {
    client_id     = data.azurerm_key_vault_secret.kafka_poc_spn_id.value
    client_secret = data.azurerm_key_vault_secret.kafka_poc_spn_secret.value
  }
  tags = {
    cluster = "kafka-poc"
    env = "dev"
  }
}
