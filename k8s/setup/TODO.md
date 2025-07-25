# SELF-MANAGED KUBERNETES CLUSTER SETUP ON GOOGLE COMPUTE ENGINE

## EXPOSE THESE PORTS FOR THE CONTROL PLANE AND WORKER NODES USING FIREWALL RULES

**Control plane**

- API server - 6443
- etcd server client API - 2379-2380
- Kubelet API - 10250
- Kube-scheduler - 10251
- kube-controller-manager - 10252

**Worker node**

- Kubelet API - 10250
- Kube-proxy - 10256
- NodePort Services - 30000-32767
- Load Balancer - TCP:80
  - Tags: `k8s-node`, `kubernetes-node`
  - Source IP ranges: `130.211.0.0/22`, `35.191.0.0/16`

## SET UP THE MASTER AND WORKER NODES

- Run the `common.sh` script on the Master Node and Worker Nodes to install the required packages and configure the K8s cluster.
- Run the `master.sh` script on the Master Node to initialize the K8s cluster.

## COMMAND TO PRINT THE K8S TOKEN TO ADD THE WORKER NODES TO THE CONTROL PLANE

`kubeadm token create --print-join-command`

## CREATE A SERVICE ACCOUNT WITH THE FOLLOWING ROLES

- Compute Admin
- Storage Admin
- Service Account User
- Compute Network Admin
- Compute Load Balancer Admin
- Service Usage Viewer
- Viewer
- Service Usage Admin
- Artifact Registry Reader

Attach the Service Account to the Master and Worker Node instance templates

## SET UP THE GOOGLE CLOUD CONTROLLER MANAGER

- Disable the Built-In Cloud Controller `sudo nano /etc/kubernetes/manifests/kube-controller-manager.yaml`

  - Remove the flag - `--cloud-provider=external` or `--cloud-provider=gcp`
  - Remove any other cloud-related flags like `--cloud-config`
  - Add the `nodeipam` to the list of controllers `--controllers=*,bootstrapsigner,tokencleaner,nodeipam`

- Edit kube-apiserver: `sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml`

  - Add this flag to the command: `- --cloud-provider=external`
  <!-- - Also this `- --allocate-node-cidrs=true`
  - And this `- --cluster-cidr=192.168.0.0/16` -->

- **On all worker nodes:**:

  - Edit the kubelet config: `sudo nano /var/lib/kubelet/kubeadm-flags.env`
    - Set the cloud provider: `KUBELET_KUBEADM_ARGS=--config=/var/lib/kubelet/config.yaml --cloud-provider=external ...`
  - Then restart kubelet:

  ```bash
  sudo systemctl daemon-reexec
  sudo systemctl restart kubelet
  ```

- Create the Google CCM config file in the config directory, i.e. `sudo touch /etc/kubernetes/cloud.config/gcp-ccm.conf`.

  - Add the network-tags which were added to your nodes to the config file `sudo nano /etc/kubernetes/cloud.config/gcp-ccm.conf`:

  ```
  [global]
  node-tags = k8s-node
  node-tags = kubernetes-node
  ```

- Download the manifest `curl -L https://raw.githubusercontent.com/kubernetes/cloud-provider-gcp/master/deploy/packages/default/manifest.yaml -o ./online-auction-kubernetes/manifests/gcp-ccm.yaml`

- Check the Cluster's CIDR range - `kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'`, ensure to use the 1st 2 numbers in all the ranges.

  - E.g. If the above comand returns something like this `192.168.0.0/24 192.168.1.0/24`, or this `192.168.0.0/24 192.168.1.0/24 192.168.2.0/24` (the IP addresses available are dependent on the no. of Nodes).
  - Hence, the CIDR range will be `192.168.0.0/16`

- Update the `gcp-ccm.yaml` manifest

  - Add the `container.args` parameter
    - Add the `- "--cloud-provider=gce"`, `- "--cluster-cidr=<CLUSTER_NETWORK_CIDR>"`, `--allocate-node-cidrs=true`, & `--cloud-config=/etc/kubernetes/cloud.config/gcp-ccm.conf` arguments to the list of args
  - Add the `command` parameter

- Retrieve the internal IP address of the Master Node - `gcloud compute instances describe <MASTER_NODE_VM_NAME> --zone=<MASTER_NODE_VM_ZONE> --format='get(networkInterfaces[0].networkIP)'`.

  - E.g. `gcloud compute instances describe k8s-master-node --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)'`

- Add the below environment variables to the manifest file

```yaml
env:
  - name: KUBERNETES_SERVICE_HOST
    value: "<MASTER_NODE_VM_INTERNAL_IP_ADDRESS>"
  - name: KUBERNETES_SERVICE_PORT
    value: "6443"
  - name: GOOGLE_APPLICATION_CREDENTIALS
    value: ""
```

- Add the below configuration at the end of the manifest

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:cloud-controller-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:cloud-controller-manager
subjects:
  - kind: ServiceAccount
    name: cloud-controller-manager
    namespace: kube-system
```

- Label the nodes accordingly
  - Run this command for every new worker node added to the Cluster

```bash
# Master Node
kubectl patch node <MASTER-NODE> -p \
'{"spec":{"providerID":"gce://<PROJECT-ID>/<ZONE>/<MASTER-NODE>"}}'

# Worker Nodes
kubectl patch node <WORKER-NODE> -p \
'{"spec":{"providerID":"gce://<PROJECT-ID>/<ZONE>/<WORKER-NODE>"}}'
```

E.g.

```bash
kubectl patch node k8s-master-node -p \
'{"spec":{"providerID":"gce://kubernetes-practice-462208/us-central1-a/k8s-master-node"}}'

kubectl patch node k8s-worker-node -p \
'{"spec":{"providerID":"gce://kubernetes-practice-462208/us-central1-a/k8s-worker-node"}}'
```

- Apply the manifest file: `kubectl apply -f ./online-auction-kubernetes/self-managed/manifests/gcp-ccm.yaml`

### TEMP

- Run this command in the Controle Plane Node to authenticate Google CCM

```bash
kubectl create clusterrole cloud-controller-patch-nodes \
  --verb=patch,update,get \
  --resource=nodes

kubectl create clusterrolebinding cloud-controller-patch-nodes \
  --clusterrole=cloud-controller-patch-nodes \
  --serviceaccount=kube-system:cloud-controller-manager
```

- Check if `providerID` is attached to nodes `kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name}: {.spec.providerID}{'\n'}{end}"`

- Chack permissions `kubectl auth can-i patch node --as=system:serviceaccount:kube-system:cloud-controller-manager`

- Get Google CCM logs `kubectl logs -n kube-system -l component=cloud-controller-manager`
- Modify the worker node label `kubectl label nodes k8s-worker-node-1 cloud.google.com/gke-nodepool=default-pool`

## Set up Persistent Volumes

- Create the GCP CSI Driver namespace `kubectl create namespace gce-pd-csi-driver`

- Download the GCP CSI Driver release `curl -L -o gcp-csi-driver.tar.gz https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver/archive/refs/tags/v1.20.0.tar.gz`

- Navigate to the `deploy\kubernetes\images\stable-master\image.yaml`.
  - Update the CSI image tag in the `newName` property from `us-central1-docker.pkg.dev/enginakdemir-gke-dev/csi-dev/gcp-compute-persistent-disk-csi-driver` to `registry.k8s.io/cloud-provider-gcp/gcp-compute-persistent-disk-csi-driver` at the bottom of the file, also update the `newTag` property from `latest` to `v1.15.1`.

```yaml
apiVersion: builtin
kind: ImageTagTransformer
metadata:
  name: imagetag-gcepd-driver
imageTag:
  name: gke.gcr.io/gcp-compute-persistent-disk-csi-driver
  # Don't change stable image without changing pdImagePlaceholder in
  # test/k8s-integration/main.go
  newName: registry.k8s.io/cloud-provider-gcp/gcp-compute-persistent-disk-csi-driver
  newTag: "v1.15.1"
```

- Apply the CSI driver k8s manifests `kubectl apply -k gcp-compute-persistent-disk-csi-driver-1.20.0/deploy/kubernetes/overlays/stable-master/`

## CONFIGURE CORE DNS

- Run the core dns rolebinding manifest to properly provide coredns with access to the k8s api server and services `kubectl apply -f ./online-auction-kubernetes/self-managed/manifests/core-dns-rolebinding.yml`
- Redeploy the coredns pods, so they pick up the new permissions `kubectl -n kube-system rollout restart deployment/coredns`

**OPTIONAL**

- Also make sure to modify the kubelet config: `sudo nano /var/lib/kubelet/kubeadm-flags.env`

  - Set the kubelet config file path: `KUBELET_KUBEADM_ARGS=--config=/var/lib/kubelet/config.yaml...`
  - Then restart kubelet:

  ```bash
  sudo systemctl daemon-reexec
  sudo systemctl restart kubelet
  ```

## CONFIGURE CALICO NETWORKING

- Install the necessary Calico CRDs `kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/crds.yaml`
  **Optional**
- Deploy Calico network using this manifest `kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml`

## CONNECT TO K8S CLUSTER

```powershell
$env:KUBECONFIG="$HOME\.kube\config;$HOME\.kube\self-managed-config"
kubectl config view --flatten --merge > $HOME\.kube\merged-config
rm $HOME\.kube\config.backup
mv $HOME\.kube\config $HOME\.kube\config.backup
mv $HOME\.kube\merged-config $HOME\.kube\config
kubectl config get-contexts
kubectl config use-context kubernetes-admin@kubernetes
```

## TEST SERVICE CONNECTION

kubectl run dnsutils --rm -it --image=busybox:1.28 --restart=Never -- sh
nslookup kubernetes

kubectl run curlpod --rm -it --image=radial/busyboxplus:curl --restart=Never -- sh
curl -k https://kubernetes.default.svc.cluster.local:443/healthz

## Set up Argo CD

kubectl create namespace argocd
curl -sSL -o argocd-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

## SET UP GOLDILOCKS FOR VPA

- Annotate the default namespace with the VPA resource policy for Goldilocks

```bash
kubectl annotate namespace default \
  goldilocks.fairwinds.com/vpa-resource-policy='{
    "containerPolicies": [
      {
        "containerName": "geth",
        "minAllowed": {
          "cpu": "100m",
          "memory": "500Mi"
        },
        "maxAllowed": {
          "cpu": 4,
          "memory": "8Gi"
        },
        controlledResources: [ "cpu", "memory" ],
        controlledValues: "RequestsAndLimits"
      },
      {
        "containerName": "istio-proxy",
        "mode": "Off"
      }
    ]
  }'\
  --overwrite
```

- Install Goldilocks using the Helm chart

```bash
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks
```

- Enable the Default namespace for Goldilocks

```bash
kubectl label ns default goldilocks.fairwinds.com/enabled=true
```

## SET UP LOKI

- Create/update your monitoring values file, upgrade/install the `kube-prometheus-stack` Helm chart the following values.

```bash
# Create/update your monitoring values file
cat > monitoring-with-loki.yaml << 'EOF'
grafana:
  additionalDataSources:
    - name: Loki
      type: loki
      url: http://loki:3100
      access: proxy
      isDefault: false
      jsonData:
        maxLines: 1000
        derivedFields:
          - datasourceUid: prometheus
            matcherRegex: "traceID=(\\w+)"
            name: TraceID
            url: "$${__value.raw}"
EOF

# Upgrade your existing kube-prometheus-stack
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f monitoring-with-loki.yaml
```

- Install Loki using the Helm chart

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set promtail.enabled=true
```

## SET UP K8S CLUSTER DASHBOARD

```bash
sudo -E helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
sudo -E helm repo update

# Install cert-manager first (required)
sudo -E helm repo add jetstack https://charts.jetstack.io
sudo -E helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Install Rancher
sudo -E helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=rancher.your-domain.com \
  --set bootstrapPassword=admin

# Access Rancher Dashboard
# 1. Apply ingress configuration: kubectl apply -f k8s/manifests/ingress.yml
# 2. Get LoadBalancer IP: kubectl get svc ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# 3. Access Rancher at: https://rancher.<INGRESS_IP>.nip.io
# 4. Login with: admin / admin (initial password)
# 5. Set new password when prompted
# 6. Import your local cluster for management
```

## COMMONLY USED COMMANDS

<!-- * SSH into Node -->

`ssh -i "C:\Users\Prince\Documents\keys\k8s_control_plane" onukwilip@`

<!-- * Remove duplicate host from SSH client -->

`ssh-keygen -R IP_ADDRESS`
