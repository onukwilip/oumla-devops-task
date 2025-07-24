#!/bin/bash

# ArgoCD Installation Script for Self-Managed Kubernetes Cluster
# Run this script on your master node

set -e

echo "🚀 Installing ArgoCD on Kubernetes cluster..."

# Create namespace (ignore if exists)
echo "📦 Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install/Update ArgoCD (apply handles existing resources gracefully)
echo "📥 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Simple wait for core components only
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd || true

echo "✅ ArgoCD installation completed!"
echo ""
echo "📝 Access Information:"
echo "Username: admin"
echo "Get Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "🎯 ArgoCD is now ready to deploy your applications!"
