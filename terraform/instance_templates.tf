resource "google_compute_instance_template" "k8s_master_node" {
  name         = "k8s-master-node"
  description  = "The instance template for the Kubernetes master node"
  region       = var.region
  machine_type = "e2-small"

  tags = [
    "control-plane-node",
    "k8s-node",
    "kubernetes-node"
  ]

  disk {
    source_image = "projects/debian-cloud/global/images/debian-12-bookworm-v20250513"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"
    disk_size_gb = 10
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.k8s_subnet.id

    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash

      # Update system and install Git
      sudo apt-get update -y
      sudo apt-get install -y git

      export USER="onukwilip"

      export HOME="/home/$USER"

      cd ~

      # Clone the repo
      REPO_URL="https://github.com/$USER/oumla-devops-task.git"
      CLONE_DIR="oumla-devops-task/k8s/setup"

      git clone $REPO_URL

      cd $CLONE_DIR

      chmod +x ./common.sh
      chmod +x ./master.sh

      ./common.sh

      ./master.sh

      sudo chown -R $USER:$USER /home/$USER/.kube

      cd ../manifests
      kubectl apply -f ./manifests/metrics-server.yml
    EOF

    ssh-keys = "onukwilip:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOOlTrA0LZnVWrfkmy2GL7+VZ9lli4VD2E55ZPJYdWjNHThSCBmKhSnbXEgAk/T2w4Bc6S8WAtSQDfvq/U3Z6Ki8v7MvTH20vS4tEPK4aXKJQsTW40eip4BBlyEntPFNnIIUJumEBvmNt/i2bIWpBliYvQtYXlP0PLWqC9Tz6YLAl/u7KVUoNsyoxWIG2bYUAYxk+Km8KmNkxepg7OwI+jGCN9xTfzjNz+2BUzDuHchjowJOdYc0SRs7Z2J5t6otiJfYKHBCN8uIMvjBreuAG/aeRmiyjBJIh1kQlISL+noIZkWNrhhSVLxNM1CWGmM6zbo4Oxg/H7wjCvf1V+4sNhP6DM4EgxCqLH7WxgN3U5kCB/rnxJmGrTUfjW53GrcbLLCHBeNSwvvaJPU4CJYGExcXddaiXyddEoVoLUm9uZ1Bq+WOtTG2uJydPrFRx0o6dQ1jtqJqhcESOTSVCwoeX5rD3QeS+BA+gZVUSCw+FzoDmGgiUGdwiQOxgYvW2ETBIfDc/Eg6kboQvfxU5A3faA7TuZEFKoIMZjpyBUVZTLATTMsHO4HPO/VPVxx2/btabcZNbgZeLKgIuNaJYaYWaxE5t+t7QxFV6/aiUXsl57I8Z2HM5m25MDaYHglrQwgKPriKgPgq91P7/B/jbK2CSLPoBMULX7EVWDYK9X9SKhyw== onukwilip@gmail.com"
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
    automatic_restart   = true
    preemptible         = false
  }

  service_account {
    email  = google_service_account.k8s_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Confidential instance config
  confidential_instance_config {
    enable_confidential_compute = false
  }

  # Advanced machine features
  advanced_machine_features {
    enable_nested_virtualization = false
  }

  # Reservation affinity
  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  can_ip_forward = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "k8s_worker_node" {
  name         = "k8s-worker-node"
  description  = "The instance template for the Kubernetes worker node"
  region       = var.region
  machine_type = "e2-medium"

  tags = [
    "worker-node",
    "k8s-node",
    "kubernetes-node"
  ]

  disk {
    source_image = "projects/debian-cloud/global/images/debian-12-bookworm-v20250513"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"
    disk_size_gb = 10
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.k8s_subnet.id

    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash

      # Update system and install Git
      sudo apt-get update -y
      sudo apt-get install -y git

      export HOME="/home/onukwilip"

      cd ~

      # Clone the repo
      REPO_URL="https://github.com/onukwilip/oumla-devops-task.git"
      CLONE_DIR="oumla-devops-task/k8s/setup"

      git clone $REPO_URL

      cd $CLONE_DIR

      chmod +x ./common.sh

      ./common.sh
    EOF

    ssh-keys = "onukwilip:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwFUn9lO/ktiluloJPkAVXeM3qYww41EJh/p2AHv28sgiLrv36eRdQ6ROisLONxQJHbz9+T/x73Ixslye8IYNETJvz6vV6ewJiOiNnoeDgFHQJ6pl6Z8mrsp/QcEhwvUqmgB6/f9Eb5Ue1vDkPy4OEzaEuWmNjrQWSuKQeq0H+RB1PBJzeYnBSWt8OBZaCztL0K+GsBC2ZQgHXje/9Oomo1PiFTCYCM1K9a06d5mVfkPKJGKRdCOs6sczCyKVCyJvqkBYEfQqQt40+i1M2+4Vc8RFrmkHNwyTwKFvbReZXXtZWMked2a6e/frXXn8uVk8cgXwSxQtS4tMREeW2NuPVws5rDUylJmNPSUB+2LMSo0XrYt4xw8fb6pnqKz4N+ffnj4vhxBnR91f37mCOCEqO6nbOdLvL1itAekEWeJ2LJW3DSY7YLwlVPGC+8lzbLsR/L4/1kq8WLOzorfvhfYOuBxGNI9CoL2cUWIuVqe13EPhGZa0K8U/xbZ4qLt7ow0IpLIfHHeUoCqu9V0dwWEYBr/IVjrokUEyZXRX9kZN5q0m35TlaHQM7bj5FBBeRZCLpCGIV5Oy1N2nH8gjIL37gHQgcjbQLCHj4OuTZTXUUR3dCtR06SEpNg/DJUQU1u2QhLBq2Fltt6ZXH5Pr2nCURFPJ2ThAr10wgxWeXQl123w== onukwilip@gmail.com"
  }

  scheduling {
    on_host_maintenance         = "TERMINATE"
    provisioning_model          = "SPOT"
    automatic_restart           = false
    preemptible                 = true
    instance_termination_action = "STOP"
  }

  service_account {
    email  = google_service_account.k8s_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Confidential instance config
  confidential_instance_config {
    enable_confidential_compute = false
  }

  # Advanced machine features
  advanced_machine_features {
    enable_nested_virtualization = false
  }

  # Reservation affinity - No reservation for spot instances
  reservation_affinity {
    type = "NO_RESERVATION"
  }

  can_ip_forward = false

  lifecycle {
    create_before_destroy = true
  }
}

# Create the Kubernetes Master Node from template
resource "google_compute_instance_from_template" "k8s_master" {
  name = "k8s-master-node"
  zone = var.zone

  source_instance_template = google_compute_instance_template.k8s_master_node.id

  # Override any template settings if needed
  can_ip_forward = false

  allow_stopping_for_update = true
}

# Create the Kubernetes Worker Nodes from template
resource "google_compute_instance_from_template" "k8s_workers" {
  count = var.worker_node_count
  name  = "k8s-worker-node-${count.index + 1}"
  zone  = var.zone

  source_instance_template = google_compute_instance_template.k8s_worker_node.id

  # Override any template settings if needed  
  can_ip_forward = false

  allow_stopping_for_update = true

  depends_on = [google_compute_instance_from_template.k8s_master]
}

