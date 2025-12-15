# Terraform Azure Infrastructure

Azure infrastructure deployment with secrets managed by HashiCorp Vault.

## Architecture

- **Secrets Management**: HashiCorp Vault running on Kubernetes (home lab)
- **Infrastructure as Code**: Terraform pulling credentials from Vault
- **Cloud Provider**: Microsoft Azure

## Resources Created

- Resource Group
- Virtual Network (10.0.0.0/16)
- Subnet (10.0.1.0/24)
- Network Security Group (SSH allowed)

## Prerequisites

- Vault accessible at \http://192.168.56.104:8200\
- Azure credentials stored in Vault at \kv/azure/terraform\
- Terraform installed

## Usage

\\\ash
terraform init
terraform plan
terraform apply
\\\

## Vault Integration

Terraform authenticates to Azure using credentials stored in Vault:

\\\hcl
data "vault_kv_secret_v2" "azure" {
  mount = "kv"
  name  = "azure/terraform"
}

provider "azurerm" {
  client_id       = data.vault_kv_secret_v2.azure.data["client_id"]
  client_secret   = data.vault_kv_secret_v2.azure.data["client_secret"]
  tenant_id       = data.vault_kv_secret_v2.azure.data["tenant_id"]
  subscription_id = data.vault_kv_secret_v2.azure.data["subscription_id"]
}
\\\

## Related

- [terraform-learning](https://github.com/avaneswaran/terraform-learning) - Kubernetes + Vault home lab
