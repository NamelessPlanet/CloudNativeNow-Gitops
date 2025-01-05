resource "civo_network" "cloudnativenow" {
  label = "cloudnativenow-network"
}

resource "civo_firewall" "cloudnativenow" {
  name                 = "cloudnativenow-firewall"
  network_id           = civo_network.cloudnativenow.id

  create_default_rules = false

  # Web access
  ingress_rule {
    label      = "http-tcp"
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "http-udp"
    protocol   = "udp"
    port_range = "80"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "https-tcp"
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "https-udp"
    protocol   = "udp"
    port_range = "443"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }

  # Kubernetes API Server
  ingress_rule {
    label      = "kube-api-tcp"
    protocol   = "tcp"
    port_range = "6443"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "kube-api-udp"
    protocol   = "udp"
    port_range = "6443"
    cidr       = ["0.0.0.0"]
    action     = "allow"
  }

  # Database access from own network
  ingress_rule {
    label      = "database-tcp"
    protocol   = "tcp"
    port_range = "3306"
    cidr       = [civo_network.cloudnativenow.cidr_v4]
    action     = "allow"
  }
  ingress_rule {
    label      = "database-udp"
    protocol   = "udp"
    port_range = "3306"
    cidr       = [civo_network.cloudnativenow.cidr_v4]
    action     = "allow"
  }

  # Allow everything out
  egress_rule {
    label      = "all-tcp"
    protocol   = "tcp"
    port_range = "1-65535"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  egress_rule {
    label      = "all-udp"
    protocol   = "udp"
    port_range = "1-65535"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
}

resource "civo_kubernetes_cluster" "cloudnativenow" {
  name        = "CloudNative.now"
  firewall_id = civo_firewall.cloudnativenow.id
  network_id  = civo_network.cloudnativenow.id

  cluster_type       = "k3s"
  kubernetes_version = "1.30.5-k3s1"
  cni                = "flannel"

  write_kubeconfig = true

  pools {
    size       = "g4s.kube.small"
    node_count = 2
  }

  lifecycle {
    ignore_changes = [
      pools["node_count"],
    ]
  }
}

resource "civo_database" "cloudnativenow" {
  name    = "cloudnativenow"
  firewall_id = civo_firewall.cloudnativenow.id
  network_id  = civo_network.cloudnativenow.id

  size    = "g3.db.xsmall"
  nodes   = 1
  engine  = "MySQL"
  version = "8.0"
}

resource "flux_bootstrap_git" "cloudnativenow" {
  embedded_manifests = true
  path               = "flux"
}

resource "kubernetes_secret" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-civo"
    namespace = "kube-system"
  }

  type = "Opaque"

  data = {
    CIVO_API_KEY = "${var.civo_api_key}"
    CIVO_API_URL = "https://api.civo.com"
    CIVO_CLUSTER_ID = "${civo_kubernetes_cluster.cloudnativenow.id}"
    CIVO_REGION = "${var.region}"
  }
}

resource "kubernetes_secret" "ghost-database-password" {
  metadata {
    name = "ghost-database"
    namespace = "ghost"
  }

  type = "Opaque"

  data = {
    "mysql-password" = "${civo_database.cloudnativenow.password}"
  }
}

