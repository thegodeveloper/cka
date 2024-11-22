# Update Cluster with Kubeadm

Organize this note with all the process to upgrade the control-plane and worker nodes.

## Create the cluster

```shell
kind create cluster --name cka --config yaml-definitions/cluster.yaml
```

## Connect to cka-control-plane

```shell
docker exec -it cka-control-plane bash
```

## Upgrade the cka-control-plane node

### Get kubeadm upgrade plan

```shell
kubeadm upgrade plan
```

#### Output

```shell
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     3 x v1.29.0   v1.29.7

Upgrade to the latest version in the v1.29 series:

COMPONENT                 CURRENT    TARGET
kube-apiserver            v1.29.0    v1.29.7
kube-controller-manager   v1.29.0    v1.29.7
kube-scheduler            v1.29.0    v1.29.7
kube-proxy                v1.29.0    v1.29.7
CoreDNS                   v1.11.1    v1.11.1
etcd                      3.5.10-0   3.5.10-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.29.7

Note: Before you can perform this upgrade, you have to update kubeadm to v1.29.7.
```

### Installing Requirements

```shell
apt update
apt-get install -y apt-transport-https ca-certificates curl gpg
```

### Create keyrings directory

```shell
mkdir -p -m 755 /etc/apt/keyrings
```

### Download the public key

```shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### Add the appropriate Kubernetes apt repository

```shell
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
```

### Update the apt package index

```shell
apt-get update
```

### Get the kubeadm version to update

```shell
apt-cache madison kubeadm
   kubeadm | 1.29.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.4-2.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
```

### Update the kubeadm to a specific version

```shell
apt-mark unhold kubeadm
apt-get install -y kubeadm=1.29.7-1.1 kubelet=1.29.7-1.1
apt-mark hold kubeadm
apt-mark hold kubelet
```

### Prepare the node for maintenance

```shell
root@cka-control-plane:/# kubectl drain cka-control-plane --ignore-daemonsets
node/cka-control-plane cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-qjw6x, kube-system/kube-proxy-ptpc4
evicting pod local-path-storage/local-path-provisioner-7577fdbbfb-dngrc
evicting pod kube-system/coredns-76f75df574-5fght
evicting pod kube-system/coredns-76f75df574-mj4sr
pod/coredns-76f75df574-mj4sr evicted
pod/coredns-76f75df574-5fght evicted
pod/local-path-provisioner-7577fdbbfb-dngrc evicted
node/cka-control-plane drained
root@cka-control-plane:/#
```

### Verify the state of the nodes

```shell
root@cka-control-plane:/# kubectl get nodes
NAME                STATUS                     ROLES           AGE   VERSION
cka-control-plane   Ready,SchedulingDisabled   control-plane   19m   v1.29.0
cka-worker          Ready                      <none>          18m   v1.29.0
cka-worker2         Ready                      <none>          18m   v1.29.0
root@cka-control-plane:/#
```

### Apply the kubeadm version

```shell
kubeadm upgrade apply v1.29.7
...
[upgrade] Are you sure you want to proceed? [y/N]: y
```

### Restart kubelet

```shell
systemctl daemon-reload
systemctl restart kubelet
```

### Validate the version in control-plane

```shell
root@cka-control-plane:/# kubectl get nodes
NAME                STATUS                     ROLES           AGE   VERSION
cka-control-plane   Ready,SchedulingDisabled   control-plane   28m   v1.29.7
cka-worker          Ready                      <none>          27m   v1.29.0
cka-worker2         Ready                      <none>          27m   v1.29.0
```

### Uncordon the node

```shell
kubectl uncordon cka-control-plane
node/cka-control-plane uncordoned
```

### Validate the version in control-plane again

```shell
root@cka-control-plane:/# kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   28m   v1.29.7
cka-worker          Ready    <none>          28m   v1.29.0
cka-worker2         Ready    <none>          28m   v1.29.0
```

## Upgrade a worker node

### Connect to the worker node

```shell
docker exec -it cka-worker bash                                                                                                                                                                    ─╯
root@cka-worker:/#
```

### Installing Requirements

```shell
apt update
apt-get install -y apt-transport-https ca-certificates curl gpg
```

### Create keyrings directory

```shell
mkdir -p -m 755 /etc/apt/keyrings
```

### Download the public key

```shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### Add the appropriate Kubernetes apt repository

```shell
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
```

### Update the apt package index

```shell
apt-get update
```

### Upgrade Kubeadm

```shell
apt-mark unhold kubeadm
apt-mark unhold kubelet

apt-get update && apt-get install -y kubeadm=1.29.7-1.1 kubelet=1.29.7-1.1

apt-mark hold kubeadm
apt-mark hold kubelet
```

### Call Upgrade kubeadm

```shell
kubeadm upgrade node
```

### Drain the node

```shell
kubectl drain cka-worker --ignore-daemonsets
kubectl drain cka-worker2 --ignore-daemonsets
```

### Restart kubelet

```shell
systemctl daemon-reload
systemctl restart kubelet
```

### Uncordon the node

```shell
kubectl uncordon cka-worker
kubectl uncordon cka-worker2
```

### Validate nodes state

```shell
k get nodes                                                                                                                                                                  ─╯
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   44m   v1.29.7
cka-worker          Ready    <none>          44m   v1.29.7
cka-worker2         Ready    <none>          44m   v1.29.7
```