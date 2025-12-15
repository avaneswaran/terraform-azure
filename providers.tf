terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.23"
    }
  }
}

# Vault provider - pulls secrets from your lab
provider "vault" {
  address = "http://192.168.56.104:8200"
  token   = "root"
}

# Read Azure credentials from Vault
data "vault_kv_secret_v2" "azure" {
  mount = "kv"
  name  = "azure/terraform"
}

# Azure provider - uses credentials from Vault
provider "azurerm" {
  features {}
  
  client_id       = data.vault_kv_secret_v2.azure.data["client_id"]
  client_secret   = data.vault_kv_secret_v2.azure.data["client_secret"]
  tenant_id       = data.vault_kv_secret_v2.azure.data["tenant_id"]
  subscription_id = data.vault_kv_secret_v2.azure.data["subscription_id"]
}
