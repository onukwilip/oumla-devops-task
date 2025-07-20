# Create a custom VPC network for the Kubernetes cluster
resource "google_compute_network" "k8s_vpc" {
  name                    = "k8s-cluster-vpc"
  description             = "VPC network for Kubernetes cluster"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Create a subnet for the Kubernetes cluster
resource "google_compute_subnetwork" "k8s_subnet" {
  name          = "k8s-cluster-subnet"
  description   = "Subnet for Kubernetes cluster nodes"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.k8s_vpc.id

  # Enable private Google access for nodes without external IPs
  private_ip_google_access = true
}

# Firewall rule for SSH access to all nodes
resource "google_compute_firewall" "k8s_allow_ssh" {
  name        = "k8s-allow-ssh"
  description = "Allow SSH access to Kubernetes nodes"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node", "kubernetes-node"]

  priority = 1000
}

# Firewall rule for internal cluster communication
resource "google_compute_firewall" "k8s_allow_internal" {
  name        = "k8s-allow-internal"
  description = "Allow internal communication between Kubernetes nodes"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["k8s-node", "kubernetes-node"]

  priority = 1000
}

# Control Plane Firewall Rules
# API server - port 6443
resource "google_compute_firewall" "k8s_control_plane_api_server" {
  name        = "k8s-control-plane-api-server"
  description = "Allow access to Kubernetes API server"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["control-plane-node"]

  priority = 1000
}

# etcd server client API - ports 2379-2380
resource "google_compute_firewall" "k8s_control_plane_etcd" {
  name        = "k8s-control-plane-etcd"
  description = "Allow access to etcd server client API"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["2379-2380"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["control-plane-node"]

  priority = 1000
}

# Kubelet API - port 10250 (Control Plane)
resource "google_compute_firewall" "k8s_control_plane_kubelet" {
  name        = "k8s-control-plane-kubelet"
  description = "Allow access to Kubelet API on control plane"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["control-plane-node"]

  priority = 1000
}

# Kube-scheduler - port 10251
resource "google_compute_firewall" "k8s_control_plane_scheduler" {
  name        = "k8s-control-plane-scheduler"
  description = "Allow access to Kube-scheduler"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10251"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["control-plane-node"]

  priority = 1000
}

# kube-controller-manager - port 10252
resource "google_compute_firewall" "k8s_control_plane_controller_manager" {
  name        = "k8s-control-plane-controller-manager"
  description = "Allow access to kube-controller-manager"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10252"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["control-plane-node"]

  priority = 1000
}

# Worker Node Firewall Rules
# Kubelet API - port 10250 (Worker Nodes)
resource "google_compute_firewall" "k8s_worker_kubelet" {
  name        = "k8s-worker-kubelet"
  description = "Allow access to Kubelet API on worker nodes"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["worker-node"]

  priority = 1000
}

# Kube-proxy - port 10256
resource "google_compute_firewall" "k8s_worker_kube_proxy" {
  name        = "k8s-worker-kube-proxy"
  description = "Allow access to Kube-proxy"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10256"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["worker-node"]

  priority = 1000
}

# NodePort Services - ports 30000-32767
resource "google_compute_firewall" "k8s_worker_nodeport" {
  name        = "k8s-worker-nodeport"
  description = "Allow access to NodePort services"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["worker-node"]

  priority = 1000
}

# Load Balancer - TCP:80 (with specific source ranges)
resource "google_compute_firewall" "k8s_worker_load_balancer" {
  name        = "k8s-worker-load-balancer"
  description = "Allow access from Google Cloud Load Balancer"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["k8s-node", "kubernetes-node"]

  priority = 1000
}

# Allow HTTPS traffic for ingress controllers
resource "google_compute_firewall" "k8s_allow_https" {
  name        = "k8s-allow-https"
  description = "Allow HTTPS traffic to Kubernetes nodes"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node", "kubernetes-node"]

  priority = 1000
}

# Allow HTTP traffic for ingress controllers
resource "google_compute_firewall" "k8s_allow_http" {
  name        = "k8s-allow-http"
  description = "Allow HTTP traffic to Kubernetes nodes"
  network     = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-node", "kubernetes-node"]

  priority = 1000
}
