variable "resource_group_name" {
  description = "Name of the resource group for the AKS platform"
  type        = string
}

variable "location" {
  description = "Azure region where the platform resources will be deployed"
  type        = string
}