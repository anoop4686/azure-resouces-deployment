variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "rg-dev-azure-vm-01"
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "vm-dev-ubuntu-01"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux VM administrator username"
  type        = string
  default     = "anoop"
}

variable "admin_password" {
  description = "Linux VM administrator password"
  type        = string
  sensitive   = true
}
