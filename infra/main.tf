resource "civo_network" "cloudnativenow" {
  label = "cloudnativenow-network"
}

resource "civo_firewall" "cloudnativenow" {
  name       = "cloudnativenow-firewall"
  network_id = civo_network.cloudnativenow.id

  create_default_rules = false

  ingress_rule {
    label    = "ping"
    protocol = "icmp"
    cidr     = ["0.0.0.0/0"]
    action   = "allow"
  }

  # Web access
  ingress_rule {
    label      = "http-tcp"
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "http-udp"
    protocol   = "udp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "https-tcp"
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "https-udp"
    protocol   = "udp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  # Kubernetes API Server
  ingress_rule {
    label      = "kube-api-tcp"
    protocol   = "tcp"
    port_range = "6443"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  ingress_rule {
    label      = "kube-api-udp"
    protocol   = "udp"
    port_range = "6443"
    cidr       = ["0.0.0.0/0"]
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
  # Temporary access while running mysqld exporter against DB
  ingress_rule {
    label      = "local"
    protocol   = "tcp"
    port_range = "3306"
    cidr       = ["88.97.211.49/32"]
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
  egress_rule {
    label    = "ping"
    protocol = "icmp"
    cidr     = ["0.0.0.0/0"]
    action   = "allow"
  }

  lifecycle {
    ignore_changes = [
      # Needed because I initially started with default rules and then switched to custom
      # Without this the firewall would need to be re-created which cannot be done while a cluster is using it
      create_default_rules
    ]
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
  name        = "cloudnativenow"
  firewall_id = civo_firewall.cloudnativenow.id
  network_id  = civo_network.cloudnativenow.id

  size    = "g3.db.xsmall"
  nodes   = 1
  engine  = "MySQL"
  version = "8.0"
}

resource "civo_object_store" "cloudnativenow-backup" {
  name        = "cloudnativenow-backup"
  max_size_gb = 500
}

resource "flux_bootstrap_git" "cloudnativenow" {
  embedded_manifests = true
  path               = "flux"
}

resource "kubernetes_secret" "cluster-autoscaler" {
  metadata {
    name      = "cluster-autoscaler-civo"
    namespace = "kube-system"
  }

  type = "Opaque"

  data = {
    CIVO_API_KEY    = "${var.civo_api_key}"
    CIVO_API_URL    = "https://api.civo.com"
    CIVO_CLUSTER_ID = "${civo_kubernetes_cluster.cloudnativenow.id}"
    CIVO_REGION     = "${var.region}"
  }
}

resource "kubernetes_secret" "ghost-database-password" {
  metadata {
    name      = "ghost-database"
    namespace = "ghost"
  }

  type = "Opaque"

  data = {
    "mysql-password" = "${civo_database.cloudnativenow.password}"
  }
}

resource "kubernetes_secret" "ghost-backup-creds" {
  metadata {
    name      = "ghost-backup-creds"
    namespace = "ghost"
  }

  type = "Opaque"

  data = {
    "access-key" = "${civo_object_store.cloudnativenow-backup.access_key_id}"
  }
}

