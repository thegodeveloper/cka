#!/bin/zsh

cd ../../

####### Create k8s-c1 cluster #######
echo 'creating k8s-c1 cluster'
kind create cluster --name k8s-c1 --config yaml-definitions/cluster.yaml

# Use context
kubectl config use-context kind-k8s-c1

# Lab 03
kubectl create namespace project-c13
kubectl apply -f yaml-definitions/statefulset-o3db.yaml

# Lab 04
kubectl apply -f yaml-definitions/lab4-service-am-i-ready.yaml

# Lab 07
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1 || true
helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system

# Lab 11, 12, 17
kubectl create namespace project-tiger

####### Create k8s-c2 #######
echo 'creating k8s-c2 cluster'
kind create cluster --name k8s-c2 --config yaml-definitions/cluster.yaml

####### Create k8s-c3 cluster #######
echo 'creating k8s-c3 cluster'
kind create cluster --name k8s-c3 --config yaml-definitions/cluster.yaml

# Install vim
docker exec -it k8s-c3-worker apt update
docker exec -it k8s-c3-worker apt install vim -y

# Modify the 10-kubeadm.conf file to introduce a bug in the container
docker exec -it k8s-c3-worker sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf >/dev/null 2>&1 || true

# Reload daemon
docker exec -it k8s-c3-worker systemctl daemon-reload >/dev/null 2>&1 || true

# Stop and start the kubelet process
docker exec -it k8s-c3-worker systemctl stop kubelet >/dev/null 2>&1 || true
docker exec -it k8s-c3-worker systemctl start kubelet >/dev/null 2>&1 || true

####### Create k8s-c4 cluster #######
echo 'creating k8s-c4 cluster'
kind create cluster --name k8s-c4 --config yaml-definitions/cluster.yaml

# Drain the k8s-c4-worker2 node
kubectl drain k8s-c4-worker2 --ignore-daemonsets --delete-emptydir-data >/dev/null 2>&1 || true

# Delete the node
kubectl delete node k8s-c4-worker2 >/dev/null 2>&1 || true

# Reset the node
docker exec -it k8s-c4-worker2 kubeadm reset --force >/dev/null 2>&1 || true

## Install vim on k8s-c4-control-plane
docker exec -it k8s-c4-control-plane bash -c "apt-get update" || true
docker exec -it k8s-c4-control-plane bash -c "apt-get install vim -y" || true

# Install other version
docker exec -it k8s-c4-worker2 bash -c "apt-get update" || true
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y apt-transport-https ca-certificates curl gpg" || true
docker exec -it k8s-c4-worker2 bash -c "mkdir -p -m 755 /etc/apt/keyrings" || true
docker exec -it k8s-c4-worker2 bash -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" || true
docker exec -it k8s-c4-worker2 bash -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list" || true
docker exec -it k8s-c4-worker2 bash -c "apt-get update" || true
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y kubelet=1.29.3-1.1 kubectl=1.29.3-1.1" || true
