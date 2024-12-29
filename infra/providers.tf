provider "civo" {
  region = var.region
}

provider "flux" {
  kubernetes = {
    host = civo_kubernetes_cluster.cloudnativenow.api_endpoint
    client_certificate = base64decode(
      yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).users[0].user.client-certificate-data
    )
    client_key = base64decode(
      yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).users[0].user.client-key-data
    )
    cluster_ca_certificate = base64decode(
      yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).clusters[0].cluster.certificate-authority-data
    )
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.github_repository}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}

provider "kubernetes" {
  host = civo_kubernetes_cluster.cloudnativenow.api_endpoint
  client_certificate = base64decode(
    yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).users[0].user.client-certificate-data
  )
  client_key = base64decode(
    yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).users[0].user.client-key-data
  )
  cluster_ca_certificate = base64decode(
    yamldecode(civo_kubernetes_cluster.cloudnativenow.kubeconfig).clusters[0].cluster.certificate-authority-data
  )
}
