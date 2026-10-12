terraform {
  required_version = ">= 1.5, < 2.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.236.0"
    }
  }
}

# YC_SERVICE_ACCOUNT_KEY_FILE, YC_CLOUD_ID и YC_FOLDER_ID задаются в окружении.
provider "yandex" {
  zone = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2204-lts"
  folder_id = "standard-images"
}

resource "yandex_vpc_network" "main" {
  name = "${var.project_name}-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.project_name}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.40.1.0/24"]
}

resource "yandex_vpc_security_group" "app" {
  name       = "${var.project_name}-app-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "SSH from administrator"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_disk" "data" {
  name = "${var.project_name}-data"
  zone = var.zone
  type = "network-hdd"
  size = var.data_disk_size
}

resource "yandex_compute_instance" "app" {
  name                      = "${var.project_name}-app"
  zone                      = var.zone
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores         = var.app_cores
    memory        = var.app_memory
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      name     = "${var.project_name}-app-boot"
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = var.boot_disk_size
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.data.id
    device_name = "analytics-data"
    auto_delete = false
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}
