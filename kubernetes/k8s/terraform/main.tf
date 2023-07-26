provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_compute_instance" "kube_master" {
  name        = "kube_master"
  platform_id = "standard-v2"
  count = var.count_ci

  labels = {
    tags = "docker-app"
  }
  resources {
    cores         = 2
    memory        = 8
  }

  boot_disk {
    initialize_params {
      size = 40
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 300 -i '${self.network_interface.0.nat_ip_address},' --extra-vars 'private_ip=${self.private_ip} hostname=${self.name} public_ip=${self.network_interface.0.nat_ip_address}' --private-key ${var.private_key_path} ../ansible/master-playbook.yml"
  }
}


#
#resource "yandex_compute_instance" "kube_node" {
#  name        = "kube-node-${count.index}"
#  platform_id = "standard-v2"
#  count = var.count_ci
#
#  labels = {
#    tags = "docker-app"
#  }
#  resources {
#    cores         = 2
#    memory        = 4
#    core_fraction = 20
#  }
#
#  boot_disk {
#    initialize_params {
#      size = 40
#      image_id = var.app_disk_image
#    }
#  }
#
#  network_interface {
#    subnet_id = var.subnet_id
#    nat       = true
#  }
#
#  metadata = {
#    ssh-keys = "ubuntu:${file(var.public_key_path)}"
#  }
#
#  connection {
#    type  = "ssh"
#    host  = self.network_interface.0.nat_ip_address
#    user  = "ubuntu"
#    agent = false
#    # путь до приватного ключа
#    private_key = file(var.private_key_path)
#  }
#}
#
#resource "local_file" "AnsibleInventory" {
# content = templatefile("ansible_inventory.tmpl",
#   {
#    hostnames         = yandex_compute_instance.app.*.name,
#    ansible_hosts     = yandex_compute_instance.app[*].network_interface.0.nat_ip_address,
#   }
# )
# filename = "dynamic_inventory"
#}
