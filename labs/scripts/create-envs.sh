#!/bin/zsh

cd ../../

####### Create k8s-c1 cluster #######
echo 'creating k8s-c1 cluster'
kind create cluster --name k8s-c1 --config yaml-definitions/cluster.yaml

# Use context
kubectl config use-context kind-k8s-c1

# Lab 03
kubectl apply -f yaml-definitions/statefulset-o3db.yaml

# Lab 04
kubectl apply -f yaml-definitions/lab4-service-am-i-ready.yaml

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
