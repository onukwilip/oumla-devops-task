#!/bin/bash

# Update system and install Git
sudo apt-get update -y
sudo apt-get install -y git

export USER="onukwilip"

export HOME="/home/$USER"

cd ~

# Clone the repo
REPO_URL="https://github.com/$USER/online-auction-kubernetes.git"
CLONE_DIR="online-auction-kubernetes/self-managed"

git clone $REPO_URL

cd $CLONE_DIR

chmod +x ./common.sh
chmod +x ./master.sh

./common.sh

./master.sh

sudo chown -R $USER:$USER /home/$USER/.kube

cd ../manifests
kubectl apply -f ./metrics-server.yml