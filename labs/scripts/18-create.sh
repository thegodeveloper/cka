#!/bin/zsh

cd ../../

# Create lab18 cluster
kind create cluster --name lab18 --config yaml-definitions/cluster.yaml

# Install vim
docker exec -it lab18-worker apt update
docker exec -it lab18-worker apt install vim -y

# Modify the 10-kubeadm.conf file to introduce a bug in the container
docker exec -it lab18-worker sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf >/dev/null 2>&1 || true

# Reload daemon
docker exec -it lab18-worker systemctl daemon-reload >/dev/null 2>&1 || true

# Stop and start the kubelet process
docker exec -it lab18-worker systemctl stop kubelet >/dev/null 2>&1 || true
docker exec -it lab18-worker systemctl start kubelet >/dev/null 2>&1 || true
