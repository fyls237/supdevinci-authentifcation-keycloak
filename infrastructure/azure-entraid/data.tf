data "azuread_domains" "default" {
    only_initial = true
}

data "azuread_client_config" "current" {}