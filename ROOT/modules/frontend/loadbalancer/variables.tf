variable "azure_location" { type = string }
variable "resource_group_name" { type = string }
variable "alb_name" {
  type    = string
  default = "frontend-agw"
}
variable "gateway_subnet_id" {
  description = "Dedicated /27 or larger subnet for Application Gateway"
  type        = string
}
