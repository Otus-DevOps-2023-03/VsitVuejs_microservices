variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable network_id {
description = "Network for modules"
}
variable subnet_id {
description = "Subnets for modules"
}
variable version_id {
description = "Version kubernetes"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable service_account_key_file {
  description = "key .json"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable count_ci {
  description = "count compute instance"
  # Значение по умолчанию
  default = "1"
}
