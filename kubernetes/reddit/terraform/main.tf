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

resource "yandex_kms_symmetric_key" "key-kuber" {
  name              = "key-storage"
  description       = "key-storage"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // 1 год
}

resource "yandex_iam_service_account" "sa-kuber" {
  folder_id   = var.folder_id
  description = "Service account for kuber"
  name        = "sa-kuber"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-kuber-admin-permissions" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kuber.id}"
}

resource "yandex_kubernetes_cluster" "zonal-cluster-kuber" {
  name        = "zonal-cluster-kuber"
  description = "description"

  network_id = var.network_id

  master {
    version = var.version_id
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }

    public_ip = true

  }

  service_account_id      = yandex_iam_service_account.sa-kuber.id
  node_service_account_id = yandex_iam_service_account.sa-kuber.id

  release_channel = "RAPID"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.key-kuber.id
  }
}

resource "yandex_kubernetes_node_group" "kuber-node-group" {
  cluster_id  = yandex_kubernetes_cluster.zonal-cluster-kuber.id
  name        = "kuber-node-group"
  description = "description"
  version     = var.version_id

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [var.subnet_id]
    }

    resources {
      memory = 8
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 30
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
}
