# ----------------------------------------------------------------------------
# Secret variables to be injected as envvar (capital letters for Windows systems)
# - no defaults
# - Declared as sensitive --> Not printed in console or log if used in resources
# ----------------------------------------------------------------------------


# set by environment variable TF_VAR_OTC_SDK_AK
variable "OTC_SDK_AK" {
  description = "Personal access key"
  type        = string
  sensitive   = true
}

# set by environment variable TF_VAR_OTC_SDK_SK
variable "OTC_SDK_SK" {
  description = "Personal secret key"
  type        = string
  sensitive   = true
}

# set by environment variable TF_VAR_OTC_SDK_DOMAIN_NAME
variable "OTC_SDK_DOMAIN_NAME" {
  description = "Domain Name, eg. OTC-EU-DE-000000000010000XXXXX"
  type        = string
}

# set by environment variable TF_VAR_OTC_SDK_PROJECTID
variable "OTC_SDK_PROJECTID" {
  description = "Project Id"
  type        = string
}

# set by environment variable TF_VAR_OTC_SDK_PROJECTNAME
variable "OTC_SDK_PROJECTNAME" {
  description = "Project Name, eg. eu-de_MYPROJECT"
  type        = string
}

# set by environment variable TF_VAR_OTC_IAM_ENDPOINT
variable "OTC_IAM_ENDPOINT" {
  description = "IAM Endpoint"
  type        = string
  default     = "https://iam.eu-de.otc.t-systems.com/v3"
}


terraform {
  required_providers {
    # specifies required provider, source and version
    # see https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest

    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.36.52"
    }
  }
}

# ----------------------------------------------------------------------------
# Providers settings --> OTC
# We use the AKSK auth scheme
# See https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs
# ----------------------------------------------------------------------------
#

provider "opentelekomcloud" {
  auth_url = var.OTC_IAM_ENDPOINT

  access_key = var.OTC_SDK_AK
  secret_key = var.OTC_SDK_SK 

  domain_name = var.OTC_SDK_DOMAIN_NAME
  tenant_name = var.OTC_SDK_PROJECTNAME

}
