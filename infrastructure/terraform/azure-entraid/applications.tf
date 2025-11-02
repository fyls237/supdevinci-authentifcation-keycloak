#-----------------------------------------------------------------
# Keycloak OIDC Application
#-----------------------------------------------------------------
resource "azuread_application" "keycloack_oidc" {
  display_name = "Keycloak OIDC App"
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "keycloack_oidc" {
  application_id = azuread_application.keycloack_oidc.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "keycloack_secret" {
  service_principal_id = azuread_service_principal.keycloack_oidc.object_id
  end_date_relative    = "8760h" # 1 year
}