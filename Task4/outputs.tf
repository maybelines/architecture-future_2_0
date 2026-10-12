output "network_id" {
  description = "Идентификатор созданной сети"
  value       = yandex_vpc_network.main.id
}

output "app_vm_id" {
  description = "Идентификатор VM учебного стенда"
  value       = yandex_compute_instance.app.id
}

output "app_public_ip" {
  description = "Публичный IPv4 для SSH на app"
  value       = yandex_compute_instance.app.network_interface[0].nat_ip_address
}

output "data_disk_id" {
  description = "Идентификатор отдельного диска данных"
  value       = yandex_compute_disk.data.id
}

output "ssh_app" {
  description = "Подключение к app с указанием локального закрытого ключа"
  value       = "ssh -i ${trimsuffix(pathexpand(var.ssh_public_key_path), ".pub")} ubuntu@${yandex_compute_instance.app.network_interface[0].nat_ip_address}"
}
