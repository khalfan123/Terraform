variable "location" {
  type = string
#   default = "West Europe"
}

variable "account_tier" {
  type = string
}

variable "account_replication_type" {
  type = string
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "project-alpha",
    environment = "dev"
    owner = "khalfan"
  }
}