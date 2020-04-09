variable "keyvault_rg" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "ssh_key_name" {
  type    = string
  default = "<private_key_name>"
}

variable "admin_username" {
  type    = string
  default = "kafka-poc-admin"
}

variable "azure_region" {
  type    = string
  default = "northeurope"
}

variable "resource_group" {
  type    = string
}

variable "cluster_name" {
  type    = string
  default = "kafka-poc"
}

variable "dns_name" {
  type    = string
  default = "kafka-poc"
}

# Specify a valid kubernetes version
variable "kubernetes_version" {
  type    = string
  default = "1.17.3"
}
