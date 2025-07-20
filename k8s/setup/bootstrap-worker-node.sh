#!/bin/bash

set -e

### ⚙️ Input the kubeadm join command manually or pass via env
JOIN_COMMAND="${1:-}"

if [ -z "$JOIN_COMMAND" ]; then
    echo "❌ No kubeadm join command supplied. Please run:"
    echo "  ./bootstrap-worker.sh \"kubeadm join <MASTER_IP>:6443 --token ... --discovery-token-ca-cert-hash sha256:...\""
    exit 1
fi

echo "🚀 Joining the Kubernetes cluster..."
sudo $JOIN_COMMAND

echo "🛠️ Configuring Kubelet to use external cloud provider..."
# Try to update an existing cloud-provider flag
if grep -q -- '--cloud-provider=' /var/lib/kubelet/kubeadm-flags.env; then
    sudo sed -i 's/--cloud-provider=[^ ]*/--cloud-provider=external/' /var/lib/kubelet/kubeadm-flags.env
else
    # Append it to the args
    sudo sed -i 's/^KUBELET_KUBEADM_ARGS="/KUBELET_KUBEADM_ARGS="--cloud-provider=external /' /var/lib/kubelet/kubeadm-flags.env
fi

echo "♻️ Restarting kubelet..."
sudo systemctl daemon-reexec
sudo systemctl restart kubelet

echo "✅ Worker node successfully joined and configured for Google Cloud CCM"
