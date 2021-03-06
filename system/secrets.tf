data "azurerm_key_vault" "terraform_vault" {
    name                = var.keyvault_name
    resource_group_name = var.keyvault_rg
}

data "azurerm_key_vault_secret" "ssh_public_key" {
    name         = var.ssh_key_name
    key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "kafka_poc_spn_id" {
    name         = "<sp_id_name>"
    key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "kafka_poc_spn_secret" {
    name         = "<sp_password_name>"
    key_vault_id = data.azurerm_key_vault.terraform_vault.id
}
