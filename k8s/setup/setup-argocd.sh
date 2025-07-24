#!/bin/bash

# ArgoCD Installation Script for Self-Managed Kubernetes Cluster
# Run this script on your master node

set -e

echo "🚀 Installing ArgoCD on Kubernetes cluster..."

# Check if argocd namespace exists and create if needed
echo "📦 Checking ArgoCD namespace..."
if kubectl get namespace argocd &> /dev/null; then
    echo "✅ ArgoCD namespace already exists"
else
    echo "📦 Creating ArgoCD namespace..."
    kubectl create namespace argocd
fi

# Install ArgoCD
echo "📥 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD components to be ready
echo "⏳ Waiting for ArgoCD components to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd

# Get ArgoCD admin password
# echo "🔐 Getting ArgoCD admin password..."
# ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD installation completed!"
echo ""
echo "📝 Access Information:"
echo "Username: admin"
echo ""
echo "🎯 ArgoCD is now ready to deploy your applications!"
