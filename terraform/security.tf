resource "yandex_vpc_security_group" "ping" {
  name        = "ping"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "ICMP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16","10.7.0.0/16"]
  }
  egress {
    protocol       = "ICMP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16","10.7.0.0/16"]
}
}

resource "yandex_vpc_security_group" "ssh-access" {
  name        = "ssh-access for bastion"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    security_group_id = yandex_vpc_security_group.ssh-access-local.id
    port           = 22
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 22
    security_group_id = yandex_vpc_security_group.ssh-access-local.id
}
    egress {
    protocol       = "ANY"
    description    = "Rule allows all outgoing traffic. Nodes can connect to Yandex Container Registry, Object Storage, Docker Hub, and so on."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  
}

resource "yandex_vpc_security_group" "ssh-access-local" {
  name        = "ssh-access for localhost"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.6.0.0/16", "10.5.0.0/16", "10.7.0.0/16"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows all outgoing traffic. Nodes can connect to Yandex Container Registry, Object Storage, Docker Hub, and so on."
    v4_cidr_blocks = ["10.6.0.0/16", "10.5.0.0/16", "10.7.0.0/16"]
    port           = 22
  }
    egress {
    protocol       = "ANY"
    description    = "Rule allows all outgoing traffic. Nodes can connect to Yandex Container Registry, Object Storage, Docker Hub, and so on."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "nginx-service" {
  name        = "nginx-service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "ANY"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
}
}


resource "yandex_vpc_security_group" "elasticsearch-service" {
  name        = "elasticsearch-service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
    port           = 9200
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 9200
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
}
}


resource "yandex_vpc_security_group" "grafana-service" {
  name        = "grafana-service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
    egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
}
}


resource "yandex_vpc_security_group" "kibana-service" {
  name        = "kibana-service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
}


resource "yandex_vpc_security_group" "prometheus-service" {
  name        = "prometheus-service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16", "0.0.0.0/0"]
    port           = 9090
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 9090
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16","0.0.0.0/0"]
}
  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
    port           = 9100
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 9100
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
}
}

resource "yandex_vpc_security_group" "filebeat-service" {
  name        = "filebeat service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
    port           = 5044
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 5044
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
}
}

resource "yandex_vpc_security_group" "nginx-exporter-service" {
  name        = "nginx-exporter service"
  description = "Group rules allow connections to cluster nodes over SSH. Apply the rules only for node groups."
  network_id  = yandex_vpc_network.network-main.id

  ingress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
    port           = 4040
  }
  egress {
    protocol       = "TCP"
    description    = "Rule allows connections to nodes over SSH from specified IPs."
    port           = 4040
    v4_cidr_blocks = ["10.5.0.0/16","10.6.0.0/16"]
}
}
