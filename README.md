# 🚀 Save $600+ Monthly: Self-Managed Kubernetes for Ethereum Nodes

Stop paying Google $800-1200/month for managed Kubernetes! This project shows you how to run Ethereum blockchain nodes for just $200-400/month while keeping all the benefits of professional-grade infrastructure.

## 🎯 What This Project Does

Instead of burning money on Google's expensive Kubernetes service, this project teaches you how to:

- Run Ethereum nodes on regular Google Cloud virtual machines
- Set up your own Kubernetes cluster (it's easier than you think!)
- Save **60-70% on hosting costs** compared to managed solutions
- Get the same reliability as enterprise setups

### 🔗 Live Demo

> **[See How Much You Can Save](https://demo.link)** - Real cost comparison showing exactly how much money you'll save
>
> _(Coming soon: detailed breakdown of actual monthly costs)_

---

## 🤔 Why Can't You Just Use Regular Virtual Machines?

### The Expensive Problem with Auto-Scaling VMs

Here's what happens when you try to save money by auto-scaling regular virtual machines for Ethereum nodes:

1. **Your Data Gets Corrupted**: When multiple Ethereum nodes share the same hard drive, they fight over the same files and break everything
2. **Nodes Go Out of Sync**: Each Ethereum node needs its own copy of the blockchain - sharing causes chaos
3. **You Lose Money**: Corrupted nodes mean downtime, and downtime means lost revenue
4. **Scaling Nightmare**: Adding new VMs that share storage creates more problems than it solves

### How This Project Saves Your Money AND Your Sanity

Instead of the VM mess, this setup gives each Ethereum node its own private space:

- **Each Node Gets Its Own Storage**: No more fighting over files
- **Reliable Scaling**: Add nodes without breaking existing ones
- **Zero Corruption**: Each node manages its own blockchain data safely
- **Easy Management**: One system controls everything automatically

---

## 💰 How Much Money Will You Actually Save?

### Real Monthly Costs (No Marketing Fluff)

Here's exactly what you'll pay each month for running 5 Ethereum nodes:

| What You're Paying For   | Google's Managed Service | This DIY Approach | Your Savings      |
| ------------------------ | ------------------------ | ----------------- | ----------------- |
| **Monthly Hosting Bill** | $800-1200                | $200-400          | **$600-800**      |
| **Setup Difficulty**     | Click a button           | Follow this guide | Worth the effort! |
| **Control Over System**  | Limited                  | Full control      | Priceless         |

**Bottom Line**: You'll save $600-800 every single month. That's $7,200-$9,600 per year just by spending a weekend setting this up!

### Why Google Charges So Much

Google's managed Kubernetes service is convenient, but you're paying for:

- Their profit margins
- Features you probably don't need
- Premium support you might not use
- The convenience of not learning how it works

This project gives you the same reliability at a fraction of the cost.

---

## 🏗️ How Everything Gets Set Up Automatically

### No More Manual Server Setup

Everything gets built for you automatically using code that creates your Google Cloud setup:

```text
What Gets Created Automatically:
├── Your Private Network (like your own internet)
├── Security Rules (keeps bad guys out)
├── Virtual Machines (your actual computers)
│   ├── Master Computer (the boss)
│   └── Worker Computers (the employees)
├── User Permissions (who can do what)
├── Load Balancers (spreads traffic around)
└── Hard Drives (where your data lives)
```

### The Magic Deployment Process

GitHub watches your code and sets everything up automatically:

```text
What Happens When You Click "Deploy":
├── Step 1: Build all your cloud computers (10 minutes)
├── Step 2: Install Kubernetes (the manager software)
├── Step 3: Add essential tools
│   ├── ArgoCD (automatic deployments)
│   ├── Traffic Router (directs visitors)
│   ├── Monitoring Tools (health checker)
│   └── Auto-Scaler (gives more power when needed)
└── Step 4: Deploy your Ethereum nodes
```

---

## ⛓️ How Your Ethereum Nodes Stay Safe and Organized

### Why Each Node Gets Its Own Private Space

Think of it like giving each employee their own office instead of making them share a desk:

```yaml
# How Each Ethereum Node Gets Set Up
apiVersion: apps/v1
kind: StatefulSet
...
replicas: 2 # Start with 2 nodes
...
volumeClaimTemplates:
  ...
  storage: 30Gi # 30GB of private storage per node
```

**Why This Approach Prevents Expensive Disasters**:

- Each node gets its own 30GB hard drive (no sharing, no corruption)
- Stable addresses (node-0, node-1, etc.) so they can find each other
- If one node fails, others keep working (no single point of failure)
- Adding new nodes doesn't mess with existing ones

---

## 📈 Smart Scaling: Give Nodes More Power Instead of Adding More Nodes

### Why We Make Nodes Stronger, Not More Numerous

We chose to **beef up existing blockchain nodes** instead of **adding more instances**:

#### The Problem with Adding More Blockchain Nodes

```text
Why Adding More Nodes is Expensive and Slow:
├── New nodes take DAYS to download the entire blockchain
├── More nodes = more storage costs
├── Each node needs to sync 500+ GB of data
└── More complexity without much benefit
```

#### Our Smart Solution: Vertical Pod Autoscaler (VPA)

When an Ethereum node gets busy, instead of spinning up new nodes (which take forever to sync), we just give the existing node more CPU and RAM:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
...
  updateMode: "Auto" # Automatically give more resources when needed
  resourcePolicy:
    ...
    minAllowed:
        cpu: 100m # Minimum: 10% of one CPU core
        memory: 500Mi # Minimum: 500MB RAM
    maxAllowed:
        cpu: 4 # Maximum: 4 full CPU cores
        memory: 8Gi # Maximum: 8GB RAM
```

**What This Means for Your Wallet**: Instead of paying for 10 nodes that take days to become useful, you pay for 2 powerful nodes that adapt to demand instantly.

---

## 🔄 Automatic Updates: Your Nodes Stay Current Without You Lifting a Finger

### How ArgoCD Keeps Everything Running Smoothly

ArgoCD is like having a dedicated IT person watching your code 24/7:

**What Happens When You Update Your Code:**

1. You push changes to GitHub (like updating Ethereum node settings)
2. ArgoCD notices **"Hey, something changed!"**
3. ArgoCD compares what's running vs what should be running
4. ArgoCD automatically updates your nodes with zero downtime
5. If something breaks, ArgoCD can roll back instantly

**What This Means**: You update your code once, and all your Ethereum nodes get updated automatically. No more logging into servers, no more manual updates, no more "oops I forgot to update that one server."

---

## 📊 Know Exactly What's Happening (Before Problems Cost You Money)

### Prometheus + Grafana: Your System's Health Dashboard

Instead of guessing if your nodes are healthy, you get real-time dashboards showing exactly what's happening:

**What You Can Monitor**:

- **Your Servers**: CPU usage, memory, disk space (catch problems before they crash)
- **Your Ethereum Nodes**: How many blocks they've processed, connection health, sync status
- **Network Traffic**: How many people are using your nodes, response times
- **Custom Alerts**: Get notified before small problems become expensive disasters

**Grafana Dashboards Give You**:

- Visual charts you can actually understand (no technical degree required)
- Alerts sent to your phone when something needs attention
- Historical data to see trends and plan for growth
- One-click views of your entire system health

**Bottom Line**: Instead of finding out your nodes are down when customers complain, you know about problems before they happen and can fix them in minutes, not hours.

---

## 🌐 Let People Access Your Ethereum Nodes from Anywhere

### Opening Your Nodes to the World (Safely)

Instead of keeping your Ethereum nodes locked away on your private network, this setup lets anyone on the internet connect to them:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
---
rules:
  - host: geth.34.44.192.178.nip.io # Your public address
```

**How People Connect to Your Nodes**:

- **For DApps**: `http://geth.<YOUR_IP>.nip.io` - Regular JSON-RPC calls
- **For Real-time Data**: `ws://geth.<YOUR_IP>.nip.io` - WebSocket connections
- **Manage Your System**: `https://argocd.<YOUR_IP>.nip.io` - Deployment dashboard
- **Monitor Performance**: `http://grafana.<YOUR_IP>.nip.io` - Health dashboard

**Why This Matters**: Your Ethereum nodes become a service other developers can use. Instead of them spending days setting up their own nodes, they can just point their apps to your reliable, always-on nodes.

---

## 🚀 Getting Started: From Zero to Running Ethereum Nodes in 30 Minutes

### ⚠️ Important: Do These Steps Yourself (Don't Automate)

Before the magic happens, you need to do a few things manually. Think of these as laying the foundation for your house - you want to be very careful about this part:

#### 1. Read These Guides First

Take 15 minutes to read and follow these three guides:

- **[SIMPLE_BACKEND_SETUP.md](SIMPLE_BACKEND_SETUP.md)** - Set up secure storage for your Terraform configuration
- **[SERVICE_ACCOUNT.md](SERVICE_ACCOUNT.md)** - Create an account that can authenticate Terrform to build your infrastructure on GCP
- **[REQUIRED_APIS.md](REQUIRED_APIS.md)** - Turn on the Google Cloud features you'll need

#### 2. Why You Shouldn't Automate These Steps

**🚨 These are like the keys to your house - you don't want a robot making them**:

- **Service Accounts**: Give access to your entire Google Cloud account and billing
- **API Settings**: Can accidentally enable expensive services you don't need
- **Storage Setup**: Where your system remembers everything - mess this up and you start over
- **Security Keys**: These unlock your servers - you want to control who has them

**Simple Way to Think About It**: Would you give a robot your credit card and tell it to "go set up my business"? Probably not! Same idea here.

### GitHub Setup

#### 1. Required Secrets

Add these to your GitHub repository secrets:

```bash
# GCP Authentication
GCP_SERVICE_ACCOUNT          # Service account JSON key
PROJECT_ID                   # Your GCP project ID

# SSH Keys for VM Access
MASTER_SSH_KEY              # Private SSH key for master node
WORKER_SSH_KEY              # Private SSH key for worker nodes
```

#### 2. Required Variables

Add these to your GitHub repository variables:

```bash
PROJECT_ID                  # Your GCP project ID
```

#### 3. Generate SSH Keys

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s_cluster_key

# Add public key to GCP metadata
You can add this to the GitHub Actions Secrets

# Add private key to GitHub Secrets
cat ~/.ssh/k8s_cluster_key  # Copy this to MASTER_SSH_KEY and WORKER_SSH_KEY
```

### Infrastructure Deployment

#### 1. Run Infrastructure Pipeline

1. Go to **GitHub Actions** → **"Set up Cluster on Compute Engine VMs"**
2. Configure parameters:
   ```
   new_cluster: ✅ true
   worker_count: 5          # Minimum recommended for all services
   initial_setup: ✅ true   # Automatically install services
   ```
3. Click **"Run workflow"**

**⚠️ Important**: Use at least **5 worker nodes** to ensure proper resource distribution for:

- Geth blockchain nodes (2 replicas)
- Prometheus & Grafana monitoring
- ArgoCD and other services
- System overhead and scheduling flexibility

#### 2. Monitor Deployment

The pipeline will automatically:

1. **Deploy Infrastructure** (~10 minutes)
2. **Bootstrap Kubernetes** (~5 minutes)
3. **Install Services** (~10 minutes)
4. **Configure Monitoring** (~5 minutes)

**Total Time**: ~30 minutes for complete production-ready cluster

#### 3. Access Your Services

After deployment, SSH into your master node and access your services via:

```bash
# Get external IP
kubectl get svc ingress-nginx-controller -n ingress-nginx

# Access points (replace <IP> with actual IP)
ArgoCD:   https://argocd.<IP>.nip.io
Grafana:  http://grafana.<IP>.nip.io
Geth:     http://geth.<IP>.nip.io
```

---

## 🧪 Development Setup (Local Kubernetes)

For development and testing, you can deploy just the Geth nodes on local Kubernetes:

### Using Minikube

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192

# 2. Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 3. Deploy Geth using Helm chart
helm install geth ./helm/charts/geth-1.0.9.tgz \
  -f ./helm/values/goeth.yml \
  --namespace default

# 4. Check deployment
kubectl get pods
kubectl get pvc

# 5. Port forward for local access
kubectl port-forward service/geth 8545:8545

# 6. Access JSON-RPC endpoint
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### Development Configuration

For local development, modify the Helm values:

```yaml
# helm/values/goeth.yml
replicas: 1 # Single node for development

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 1Gi

persistence:
  size: 10Gi # Smaller storage for dev

# Use testnet for faster sync
extraArgs:
  - "--sepolia"
  - "--http"
  - "--http.api=eth,net,web3"
```

### Local Monitoring (Optional)

```bash
# Install Prometheus stack for local monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Access Grafana
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
# Visit http://localhost:3000 (admin/prom-operator)
```

---

## 📋 Project Structure

```
oumla-devops-task/
├── .github/workflows/           # CI/CD pipelines
│   ├── set-up-infrastructure.yml
│   ├── setup-cluster-services.yml
│   └── destroy-infrastructure.yml
├── terraform/                   # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── *.tf
├── k8s/                        # Kubernetes configurations
│   ├── manifests/
│   │   ├── geth-vpa.yml
│   │   ├── ingress.yml
│   │   └── argocd/
│   └── setup/                  # Setup scripts
│       ├── setup-argocd.sh
│       ├── setup-vpa.sh
│       └── *.sh
├── helm/                       # Helm charts and values
│   ├── charts/
│   │   ├── geth-1.0.9.tgz
│   │   └── ingress-nginx-4.13.0.tgz
│   └── values/
│       └── goeth.yml
├── docs/                       # Documentation
│   ├── SIMPLE_BACKEND_SETUP.md
│   ├── SERVICE_ACCOUNT.md
│   └── REQUIRED_APIS.md
└── README.md                   # This file
```

---

## 🔧 Troubleshooting

### Common Issues

**1. Pipeline Fails at Infrastructure Step**

- Verify service account permissions
- Check API enablement
- Ensure terraform backend exists

**2. Nodes Won't Join Cluster**

- Check firewall rules (ports 6443, 10250, etc.)
- Verify SSH keys are correctly configured
- Review startup script logs

**3. Geth Pods Stuck in Pending**

- Check node resources with `kubectl describe nodes`
- Verify storage class availability
- Ensure adequate worker nodes (minimum 5)

**4. Ingress Not Accessible**

- Verify LoadBalancer IP assignment
- Check DNS resolution for nip.io domains
- Review ingress controller logs

### Useful Commands

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes -o wide

# Monitor Geth pods
kubectl get pods -l app=geth
kubectl logs -f geth-0

# Check VPA recommendations
kubectl get vpa
kubectl describe vpa geth-vpa

# Verify ingress
kubectl get ingress -A
kubectl get svc -n ingress-nginx
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Ethereum Foundation](https://ethereum.org/) for Go-Ethereum
- [Kubernetes Community](https://kubernetes.io/) for orchestration platform
- [Helm Community](https://helm.sh/) for package management
- [ArgoCD Team](https://argo-cd.readthedocs.io/) for GitOps capabilities
- [Prometheus](https://prometheus.io/) & [Grafana](https://grafana.com/) for monitoring

---

**Built with ❤️ for the blockchain community**
