resource "civo_network" "cloudnativenow" {
  label = "cloudnativenow-network"
}

resource "civo_firewall" "cloudnativenow" {
  name                 = "cloudnativenow-firewall"
  create_default_rules = true
  network_id           = civo_network.cloudnativenow.id
}

resource "civo_kubernetes_cluster" "cloudnativenow" {
  name        = "CloudNative.now"
  firewall_id = civo_firewall.cloudnativenow.id
  network_id  = civo_network.cloudnativenow.id

  cluster_type       = "k3s"
  kubernetes_version = "1.30.5-k3s1"
  cni                = "cilium"

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

resource "civo_object_store" "cloudnativenow" {
  name        = "cloudnativenow"
  max_size_gb = 500
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
