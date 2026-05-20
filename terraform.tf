terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.51.1"
    }
  }
}

# Credentials are loaded from environment variables or a clouds.yaml file.
# See: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs#configuration-reference
#
# Example (PowerShell):
#   $env:OS_USERNAME = "your-username"
#   $env:OS_PASSWORD = "your-password"
#   $env:OS_TENANT_NAME = "your-tenant"
#   $env:OS_AUTH_URL = "http://kaun.uia.no:5000/v3"
#   $env:OS_USER_DOMAIN_NAME = "Default"
#   $env:OS_PROJECT_DOMAIN_NAME = "Default"

provider "openstack" {}
