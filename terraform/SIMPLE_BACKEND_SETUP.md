# Simple GCS Backend Setup

## What you need to do

### 1. Login to Google Cloud

```bash
gcloud auth login
gcloud config set project ${YOUR_PROJECT_ID}
```

### 2. Create a bucket for Terraform files

```bash
# Replace YOUR_PROJECT_ID with your actual project ID
gsutil mb gs://terraform-state-k8s-cluster-${YOUR_PROJECT_ID}

# Turn on versioning (keeps old versions of files)
gsutil versioning set on gs://terraform-state-k8s-cluster-${YOUR_PROJECT_ID}
```

### 3. Update main.tf with your bucket name

```hcl
backend "gcs" {
  bucket = "terraform-state-k8s-cluster-${YOUR_PROJECT_ID}"
  prefix = "k8s-cluster/terraform.tfstate"
}
```

### 4. Initialize Terraform

```bash
cd terraform/
terraform init
```

That's it! Terraform will now save its state files to Google Cloud Storage.

## If something goes wrong:

- Make sure you're logged in: `gcloud auth list`
- Make sure bucket exists: `gsutil ls gs://your-bucket-name`
- Make sure you have permission to the bucket
