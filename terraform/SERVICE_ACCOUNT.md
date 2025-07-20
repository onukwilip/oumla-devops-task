# Service Account for Terraform

This explains what service account and permissions you need for Terraform to work.

## What is a Service Account

A service account is like a robot user that Terraform uses to create resources in Google Cloud.

## Option 1: Use Your Personal Account (Quick Start)

```bash
gcloud auth login
gcloud auth application-default login
```

**Good for:** Testing and learning
**Bad for:** Production or teams

## Option 2: Create a Service Account (Recommended)

Add the `YOUR_PROJECT_ID` variable, and assign the project id to it

```bash
export YOUR_PROJECT_ID="your-project-id"
```

### 1. Create the Service Account

```bash
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account"
```

### 2. Give it the Right Permissions

```bash
# For GCS Backend (storing Terraform state files)
gcloud projects add-iam-policy-binding ${YOUR_PROJECT_ID} \
  --member="serviceAccount:terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# For Compute Engine (VMs, networks, disks)
gcloud projects add-iam-policy-binding ${YOUR_PROJECT_ID} \
  --member="serviceAccount:terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# For creating and managing service accounts
gcloud projects add-iam-policy-binding ${YOUR_PROJECT_ID} \
  --member="serviceAccount:terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

# For attaching service accounts to VMs
gcloud projects add-iam-policy-binding ${YOUR_PROJECT_ID} \
  --member="serviceAccount:terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# For checking enabled APIs
gcloud projects add-iam-policy-binding ${YOUR_PROJECT_ID} \
  --member="serviceAccount:terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"
```

### 3. Create a Key File

```bash
gcloud iam service-accounts keys create terraform-key.json \
  --iam-account=terraform-sa@${YOUR_PROJECT_ID}.iam.gserviceaccount.com
```

### 4. Tell Terraform to Use It

```bash
export GOOGLE_APPLICATION_CREDENTIALS="./terraform-key.json"
```

## What Permissions Does It Need

| Permission            | What It Can Do                                           |
| --------------------- | -------------------------------------------------------- |
| Storage Admin         | Create/manage GCS buckets and save Terraform state files |
| Compute Admin         | Create/manage VMs, networks, disks, firewall rules       |
| Service Account Admin | Create and manage service accounts                       |
| Service Account User  | Attach service accounts to VMs                           |
| Service Usage Viewer  | Check which APIs are enabled (for validation)            |

## Security Tips

- Don't share the key file with anyone
- Use different service accounts for different projects
- Delete old key files you don't use
- For production, use more specific permissions instead of Editor

That's all you need to know!
