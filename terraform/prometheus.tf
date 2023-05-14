resource "yandex_compute_instance" "prometheus" {
  name  = "prometheus"
  zone  = yandex_vpc_subnet.mysubnet-b.zone
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size     = 10
    }
  }
  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.mysubnet-b.id}"
    security_group_ids = [ 
      yandex_vpc_security_group.ssh-access-local.id,
      yandex_vpc_security_group.prometheus-service.id,
      yandex_vpc_security_group.nginx-exporter-service.id,
      ]
    }
}