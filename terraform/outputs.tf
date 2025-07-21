# Output the master node external IP
output "master_node_external_ip" {
  description = "External IP address of the Kubernetes master node"
  value       = google_compute_instance_from_template.k8s_master.network_interface[0].access_config[0].nat_ip
}

# Output the master node internal IP
output "master_node_internal_ip" {
  description = "Internal IP address of the Kubernetes master node"
  value       = google_compute_instance_from_template.k8s_master.network_interface[0].network_ip
}

# Output worker nodes external IPs
output "worker_nodes_external_ips" {
  description = "External IP addresses of the Kubernetes worker nodes"
  value       = google_compute_instance_from_template.k8s_workers[*].network_interface[0].access_config[0].nat_ip
}

output "worker_instance_names" {
  description = "Names of the Kubernetes worker nodes"
  value       = google_compute_instance_from_template.k8s_workers[*].name
}

# Output worker nodes internal IPs
output "worker_nodes_internal_ips" {
  description = "Internal IP addresses of the Kubernetes worker nodes"
  value       = google_compute_instance_from_template.k8s_workers[*].network_interface[0].network_ip
}

# Output worker nodes names
output "worker_nodes_names" {
  description = "Names of the Kubernetes worker nodes"
  value       = google_compute_instance_from_template.k8s_workers[*].name
}

# Output the join command for worker nodes (placeholder)
output "kubernetes_join_command" {
  description = "SSH into the master node and run 'sudo kubeadm token create --print-join-command' to get the actual join command"
  value       = "ssh onukwilip@${google_compute_instance_from_template.k8s_master.network_interface[0].access_config[0].nat_ip} 'sudo kubeadm token create --print-join-command'"
}

# Network outputs
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.k8s_vpc.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.k8s_subnet.name
}

output "subnet_cidr" {
  description = "CIDR range of the subnet"
  value       = google_compute_subnetwork.k8s_subnet.ip_cidr_range
}
