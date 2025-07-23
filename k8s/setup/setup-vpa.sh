#!/bin/bash

# Setup Vertical Pod Autoscaler (VPA) for Self-Managed Kubernetes Cluster
# Run this script on your master node

set -e

echo "🚀 Setting up VPA for Kubernetes cluster..."

# Basic checks
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Cluster connection verified"

# Check if VPA is already installed
if kubectl get crd verticalpodautoscalers.autoscaling.k8s.io &> /dev/null; then
    echo "✅ VPA CRDs already exist, checking components..."
    
    # Check individual components
    if kubectl get deployment vpa-recommender -n kube-system &> /dev/null && \
    kubectl get deployment vpa-updater -n kube-system &> /dev/null && \
    kubectl get deployment vpa-admission-controller -n kube-system &> /dev/null; then
        echo "✅ VPA is already fully installed and running!"
        echo "📝 Next: kubectl apply -f k8s/manifests/geth-vpa.yml"
        exit 0
    fi
fi

# Download and apply VPA manifests
VPA_URL="https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy"

echo "� Installing VPA CRDs..."
kubectl apply -f "$VPA_URL/vpa-v1-crd-gen.yaml"

echo "� Installing VPA RBAC..."
kubectl apply -f "$VPA_URL/vpa-rbac.yaml"

echo "🧠 Installing VPA Recommender..."
kubectl apply -f "$VPA_URL/recommender-deployment.yaml"

echo "� Installing VPA Updater..."
kubectl apply -f "$VPA_URL/updater-deployment.yaml"

echo "� Installing VPA Admission Controller..."
kubectl apply -f "$VPA_URL/admission-controller-deployment.yaml"

# Wait for components
echo "⏳ Waiting for VPA components..."
kubectl wait --for=condition=available --timeout=180s deployment/vpa-recommender -n kube-system
kubectl wait --for=condition=available --timeout=180s deployment/vpa-updater -n kube-system
kubectl wait --for=condition=available --timeout=180s deployment/vpa-admission-controller -n kube-system

echo "✅ VPA installation completed!"
echo "📝 Next: kubectl apply -f k8s/manifests/geth-vpa.yml"
