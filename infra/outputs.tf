output "kubernetes_name" {
  value       = civo_kubernetes_cluster.cloudnativenow.name
  description = "The randomly generated name for this cluster"
}

output "kubernetes_api_endpoint" {
  value       = civo_kubernetes_cluster.cloudnativenow.api_endpoint
  description = "The API endpoint of the Kubernetes cluster"
}

output "kubernetes_kubeconfig" {
  value       = civo_kubernetes_cluster.cloudnativenow.kubeconfig
  description = "The KubeConfig for the Kubernetes cluster"
  sensitive   = true
}

output "objectstore_url" {
  value       = civo_object_store.cloudnativenow.bucket_url
  description = "The URL for the objectstore"
}

output "objectstore_access_key_id" {
  value       = civo_object_store.cloudnativenow.access_key_id
  description = "The Access Key ID for the objectstore"
  sensitive   = true
}

output "database_endpoint" {
  value       = civo_database.cloudnativenow.dns_endpoint
  description = "The endpoint of the database"
}

output "database_port" {
  value       = civo_database.cloudnativenow.port
  description = "The port of the database"
}

output "database_username" {
  value       = civo_database.cloudnativenow.username
  description = "The username of the database"
}

output "database_password" {
  value       = civo_database.cloudnativenow.password
  description = "The password of the database"
  sensitive = true
}
