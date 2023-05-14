resource "yandex_compute_instance" "bastion-host" {
  name  = "bastion-host"
  zone  = yandex_vpc_subnet.mysubnet-c.zone
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
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
    subnet_id = "${yandex_vpc_subnet.mysubnet-c.id}"
    nat = true
    security_group_ids = [ 
      yandex_vpc_security_group.ssh-access.id, 
      ]
    }
}
