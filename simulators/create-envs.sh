#!/bin/zsh

## Docker Configuration
export DOCKER_CLI_HINTS=off

####### Create k8s-c1 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c1 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c1 --config yaml-definitions/cluster.yaml

echo '\n🚜 Initializing the Kubernetes cluster: k8s-c1...'

# Use context
kubectl config use-context kind-k8s-c1 >/dev/null 2>&1 || true

# Lab 03
kubectl apply -f yaml-definitions/3.yaml >/dev/null 2>&1 || true

# Lab 04
kubectl apply -f yaml-definitions/4.yaml >/dev/null 2>&1 || true

# Lab 07
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1 || true
helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system >/dev/null 2>&1 || true

# Lab 10
kubectl apply -f yaml-definitions/10.yaml >/dev/null 2>&1 || true

# Lab 06, 11, 12, 17
kubectl apply -f yaml-definitions/common.yaml >/dev/null 2>&1 || true

# Lab 24
kubectl create ns project-snake >/dev/null 2>&1 || true
kubectl -n project-snake run backend-0 --image=alpine/curl --labels app=backend --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl -n project-snake run db1-0 --image=hashicorp/http-echo --labels app=db1 --port=1111 -- --text="database one" --listen=:1111 >/dev/null 2>&1 || true
kubectl -n project-snake run db2-0 --image=hashicorp/http-echo --labels app=db2 --port=2222 -- --text="database two" --listen=:2222 >/dev/null 2>&1 || true
kubectl -n project-snake run vault-0 --image=hashicorp/http-echo --labels app=vault --port=3333 -- --text="vault secret storage" --listen=:3333 >/dev/null 2>&1 || true

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml >/dev/null 2>&1 || true

# Lab 31
kubectl run frontend --image=alpine/curl --labels app=frontend --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl run application --image=alpine/curl --labels app=application --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl run backend --image=hashicorp/http-echo --labels app=backend --port=3333 -- --text="backend tier" --listen=:3333 >/dev/null 2>&1 || true

# Lab 32
kubectl create ns project-a >/dev/null 2>&1 || true
kubectl -n project-a run backend --image=hashicorp/http-echo --labels app=backend --port=3333 -- --text="backend tier" --listen=:3333 >/dev/null 2>&1 || true
kubectl create ns project-b >/dev/null 2>&1 || true
kubectl -n project-b run web --image=alpine/curl --labels app=web --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl -n project-b run service01 --image=alpine/curl --labels app=service01 --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl create ns project-c >/dev/null 2>&1 || true
kubectl -n project-c run application --image=alpine/curl --labels app=application --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true

# Lab 33
kubectl apply -f yaml-definitions/33.yaml >/dev/null 2>&1 || true

# Lab 36
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1 || true
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.hostNetwork=true --set controller.kind=DaemonSet >/dev/null 2>&1 || true
kubectl apply -f yaml-definitions/36.yaml >/dev/null 2>&1 || true

echo '🚀 The Kubernetes cluster "k8s-c1" has been successfully prepared!\n'

####### Create k8s-c2 #######
echo '--------------------------'
echo '👉 creating k8s-c2 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c2 --config yaml-definitions/cluster.yaml

echo '\n🚜 Initializing the Kubernetes cluster: k8s-c2...'

# Install vim
docker exec -it k8s-c2-control-plane bash -c "apt update -qq > /dev/null 2>&1" 
docker exec -it k8s-c2-control-plane bash -c "apt install vim -y -qq > /dev/null 2>&1" 

echo '🚀 The Kubernetes cluster "k8s-c2" has been successfully prepared!\n'

####### Create k8s-c3 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c3 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c3 --config yaml-definitions/cluster.yaml

echo '\n🚜 Initializing the Kubernetes cluster: k8s-c3...'

# Install vim
docker exec -it k8s-c3-worker bash -c "apt update -qq > /dev/null 2>&1" 
docker exec -it k8s-c3-worker bash -c "apt install vim -y -qq > /dev/null 2>&1" 

# Modify the 10-kubeadm.conf file to introduce a bug in the container
docker exec -it k8s-c3-worker bash -c "sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf" 

# Reload daemon
docker exec -it k8s-c3-worker bash -c "systemctl daemon-reload" 

# Stop and start the kubelet process
docker exec -it k8s-c3-worker bash -c "systemctl stop kubelet" 
docker exec -it k8s-c3-worker bash -c "systemctl start kubelet" 

# Lab 25 Etcd Backup
docker exec -it k8s-c3-control-plane bash -c "curl -L https://storage.googleapis.com/etcd/v3.5.17/etcd-v3.5.17-linux-amd64.tar.gz -o /tmp/etcd-v3.5.17-linux-amd64.tar.gz >/dev/null 2>&1" 
docker exec -it k8s-c3-control-plane bash -c "mkdir /tmp/etcd-download-test" 
docker exec -it k8s-c3-control-plane bash -c "tar xzvf /tmp/etcd-v3.5.17-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1 >/dev/null 2>&1" 
docker exec -it k8s-c3-control-plane bash -c "rm -f /tmp/etcd-v3.5.17-linux-amd64.tar.gz" 
docker exec -it k8s-c3-control-plane bash -c "mv /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl" 

docker exec -it k8s-c3-control-plane bash -c "apt-get update -qq > /dev/null 2>&1" 
docker exec -it k8s-c3-control-plane bash -c "apt-get install vim -y -qq > /dev/null 2>&1" 

echo '🚀 The Kubernetes cluster "k8s-c3" has been successfully prepared!\n'

####### Create k8s-c4 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c4 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c4 --config yaml-definitions/cluster.yaml

echo '\n🚜 Initializing the Kubernetes cluster: k8s-c4...'

# Drain the k8s-c4-worker2 node
kubectl drain k8s-c4-worker2 --ignore-daemonsets --delete-emptydir-data >/dev/null 2>&1 || true

# Delete the node
kubectl delete node k8s-c4-worker2 >/dev/null 2>&1 || true

# Reset the node
docker exec -it k8s-c4-worker2 bash -c "kubeadm reset --force >/dev/null 2>&1" 

## Install vim on k8s-c4-control-plane
docker exec -it k8s-c4-control-plane bash -c "apt-get update -qq > /dev/null 2>&1" 
docker exec -it k8s-c4-control-plane bash -c "apt-get install vim -y -qq > /dev/null 2>&1" 

# Install other version
docker exec -it k8s-c4-worker2 bash -c "apt-get update -qq > /dev/null 2>&1" 
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y apt-transport-https ca-certificates curl gpg -qq > /dev/null 2>&1" 
docker exec -it k8s-c4-worker2 bash -c "mkdir -p -m 755 /etc/apt/keyrings" 
docker exec -it k8s-c4-worker2 bash -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg >/dev/null 2>&1" 
docker exec -it k8s-c4-worker2 bash -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list" 
docker exec -it k8s-c4-worker2 bash -c "apt-get update -qq > /dev/null 2>&1" 
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y kubelet=1.29.3-1.1 kubectl=1.29.3-1.1 -qq > /dev/null 2>&1"

# Question 26
kubectl apply -f yaml-definitions/26.yaml >/dev/null 2>&1 || true

# Question 28
kubectl apply -f yaml-definitions/28.yaml >/dev/null 2>&1 || true

echo '🚀 The Kubernetes cluster "k8s-c4" has been successfully prepared!\n'

####### Create k8s-c5 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c5 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c5 --config yaml-definitions/cluster.yaml

echo '\n🚜 Initializing the Kubernetes cluster: k8s-c5...'

kubectl taint nodes k8s-c5-worker node-role.kubernetes.io/node=:NoSchedule >/dev/null 2>&1 || true
kubectl cordon k8s-c5-worker2 >/dev/null 2>&1 || true

echo '🚀 The Kubernetes cluster "k8s-c5" has been successfully prepared!\n'
