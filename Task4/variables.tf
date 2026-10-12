variable "project_name" {
  description = "Префикс имён ресурсов учебного стенда"
  type        = string
}

variable "zone" {
  description = "Зона доступности VM, дисков и подсети"
  type        = string
}

variable "admin_cidr" {
  description = "Публичный IPv4 администратора с маской /32 для SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Укажите один IPv4-адрес администратора с маской /32."
  }
}

variable "ssh_public_key_path" {
  description = "Путь к существующему публичному SSH-ключу (.pub)"
  type        = string
}

variable "app_cores" {
  description = "Количество vCPU VM учебного стенда"
  type        = number
}

variable "app_memory" {
  description = "Оперативная память VM учебного стенда, ГБ"
  type        = number
}

variable "boot_disk_size" {
  description = "Размер системного диска VM, ГБ"
  type        = number
}

variable "data_disk_size" {
  description = "Размер отдельного диска аналитических данных, ГБ"
  type        = number
}
