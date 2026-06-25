variable "azure_location" { type = string }
variable "resource_group_name" { type = string }
variable "gateway_name" {
  type    = string
  default = "backend-agw"
}
variable "gateway_subnet_id" { type = string }
