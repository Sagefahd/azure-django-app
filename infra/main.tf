terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.5"
    }
  }
  required_version = ">= 1.5.0"
}
provider "azurerm" {
  features {}
  skip_provider_registration = true

}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.project_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "cae" {
  name                       = "${var.project_name}-cae"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

}


resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic" # student-safe
  admin_enabled       = true    # simplifies first push
}

data "azurerm_container_registry" "acr" {
  name                = azurerm_container_registry.acr.name
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_container_app" "app" {
  name                         = "${var.project_name}-app"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "django"
      image  = "${data.azurerm_container_registry.acr.login_server}/django-azure1:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "PORT"
        value = "8000"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = data.azurerm_container_registry.acr.login_server
    username             = data.azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = data.azurerm_container_registry.acr.admin_password
  }
}
