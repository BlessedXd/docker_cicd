variable "location" {
  type    = string
  default = "Canada Central"
}

variable "resource_group_name" {
  type    = string
  default = "resourcegroup7777s"  # Задайте тут значення за замовчуванням
}

variable "app_service_name" {
  type    = string
  default = "valeriy777servicename"  # Назва вашого App Service за замовчуванням
}

variable "admin_username" {
  type    = string
  default = "valeriy777777s7"  # Ім'я користувача за замовчуванням
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = "Valsedad87768768_32s42"  # Пароль за замовчуванням
}

variable "storage_account_name" {
  type    = string
  default = "accountval7777s"  # Назва облікового запису за замовчуванням
}

variable "tenant_id" {
  type    = string
  default = "70a28522-969b-451f-bdb2-abfea3aaa5bf"  # Ваш Azure Tenant ID за замовчуванням
}

variable "tfstate_container_name" {
  type    = string
  default = "terraform-bestrong-container"  # Контейнер для Terraform State за замовчуванням
}