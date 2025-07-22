# Deploy Your Kubernetes Cluster

Simple guide to deploy your Kubernetes infrastructure on GCP using Terraform.

## Before You Start

✅ Make sure you have:

- Service account key file (`terraform-key.json`)
- Required APIs enabled (see `REQUIRED_APIS.md`)
- Service account with proper permissions (see `SERVICE_ACCOUNT.md`)

## Step 1: Set Your Variables

Create a file called `terraform.tfvars`:

```js
project_id = "your-gcp-project-id";
region = "us-central1";
zone = "us-central1-a";
worker_node_count = 2;
```

**Required:**

- `project_id` - Your GCP project ID

**Optional (has defaults):**

- `region` - GCP region (default: us-central1)
- `zone` - GCP zone (default: us-central1-a)
- `worker_node_count` - Number of worker nodes (default: 2)

## Step 2: Initialize Terraform

```bash
# Set up authentication
export GOOGLE_APPLICATION_CREDENTIALS="./terraform-key.json"

# Initialize Terraform (downloads providers, sets up backend)
terraform init
```

## Step 3: Plan Your Deployment

```bash
# See what Terraform will create
terraform plan
```

## Step 4: Deploy Everything

```bash
# Create your Kubernetes cluster infrastructure
terraform apply
```

Type `yes` when prompted to confirm.

## What Gets Created

- **VPC Network** - Custom network for your cluster
- **Firewall Rules** - 12 rules for Kubernetes ports
- **VM Instances** - 1 master + worker nodes (configurable)
- **Service Account** - For the VMs to use

## After Deployment

Terraform will output:

- SSH commands to connect to your nodes
- IP addresses of all instances
- Kubeadm join command for workers

## Clean Up

```bash
# Destroy everything when you're done
terraform destroy
```

**Note:** If you get an error about routes blocking VPC deletion, clean them up first:
```bash
# Clean up Kubernetes-created routes
gcloud compute routes list --filter="network:k8s-cluster-vpc AND name:kubernetes*" --format="value(name)" | xargs -I {} gcloud compute routes delete {} --quiet

# Then destroy infrastructure
terraform destroy
```

---

**Need help?** Check the other docs:

- `SIMPLE_BACKEND_SETUP.md` - GCS bucket setup
- `REQUIRED_APIS.md` - Enable GCP APIs
- `SERVICE_ACCOUNT.md` - Set up permissions
