resource "yandex_alb_target_group" "ammm-1"{
  name = "ammm1"

  target {
    subnet_id = "${yandex_vpc_subnet.mysubnet-a.id}"
    ip_address   = "${yandex_compute_instance.nginx2.network_interface.0.ip_address}"
  }  

  target {
    subnet_id = "${yandex_vpc_subnet.mysubnet-b.id}"
    ip_address   = "${yandex_compute_instance.nginx1.network_interface.0.ip_address}"
  } 
}

resource "yandex_alb_backend_group" "test-backend-group" {
  name = "test-bg"
  session_affinity {
    connection {
      source_ip = false
    }
  }

  http_backend {
    name                   = "backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.ammm-1.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name   = "router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "myvirtualhost"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "my-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.test-backend-group.id
        timeout          = "3s"
      }
    }
  }
}    

resource "yandex_alb_load_balancer" "test-balancer" {
  name        = "balance7"
  network_id  = "${yandex_vpc_network.network-main.id}"
  allocation_policy {
    location {
      zone_id   = "${yandex_vpc_subnet.mysubnet-c.zone}"
      subnet_id = yandex_vpc_subnet.mysubnet-c.id
    }
  }

  listener {
    name = "lsnrport"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}

resource "yandex_compute_snapshot_schedule" "default" {
  name           = "snapshot-netology"
  schedule_policy {
    expression = "0 0 ? * *"
  }
  snapshot_count = 7
  snapshot_spec {
      description = "snapshot-description"
      labels = {
        snapshot-label = "snapshot-label-value"
      }
  }
  labels = {
    my-label = "label-value"
  }
  disk_ids = ["${yandex_compute_instance.bastion-host.boot_disk.0.disk_id}", "${yandex_compute_instance.elasticsearch.boot_disk.0.disk_id}", "${yandex_compute_instance.grafana.boot_disk.0.disk_id}", "${yandex_compute_instance.kibana.boot_disk.0.disk_id}", "${yandex_compute_instance.nginx1.boot_disk.0.disk_id}", "${yandex_compute_instance.nginx2.boot_disk.0.disk_id}", "${yandex_compute_instance.prometheus.boot_disk.0.disk_id}",]
}