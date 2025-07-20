# Google Cloud APIs to Enable

Before running Terraform, you need to turn on these APIs in your Google Cloud project.

## Required APIs

### 1. Compute Engine API

```bash
gcloud services enable compute.googleapis.com
```

**What it does:** Creates virtual machines and networks

### 2. Cloud Storage API

```bash
gcloud services enable storage-api.googleapis.com
```

**What it does:** Creates buckets and stores Terraform state files

### 3. IAM API

```bash
gcloud services enable iam.googleapis.com
```

**What it does:** Creates service accounts and manages permissions

## Enable All at Once

```bash
gcloud services enable compute.googleapis.com storage-api.googleapis.com iam.googleapis.com
```

## Check if APIs are Enabled

```bash
gcloud services list --enabled
```

## What happens if you don't enable them

- Terraform will fail with "API not enabled" errors
- You won't be able to create VMs or storage buckets
- The deployment will stop working

That's all you need!
