#!/bin/bash

set -e

# 🔧 Required values - customize these
# PROJECT_ID="kubernetes-practice-462208"
# ZONE="us-central1-a"
MANIFEST_PATH="./online-auction-kubernetes/self-managed/manifests/gcp-csi-driver/kubernetes/overlays/stable-master"

# 1 Create CSI namespace if it doesn't exist
echo "🔧 Creating CSI namespace..."
kubectl get ns gce-pd-csi-driver >/dev/null 2>&1 || kubectl create ns gce-pd-csi-driver

# 2 Apply the CSI driver manifests
echo "📦 Applying CSI driver manifests..."
kubectl apply -k "$MANIFEST_PATH"
kubectl apply -f ./online-auction-kubernetes/manifests/persistent-volume.yml

echo "✅ CSI driver configured and applied successfully!"
