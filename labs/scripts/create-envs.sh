#!/bin/zsh

cd ../../

## Docker Configuration
export DOCKER_CLI_HINTS=off

####### Create k8s-c1 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c1 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c1 --config yaml-definitions/cluster.yaml

echo '\nPreparing k8s-c1 cluster... 🚜'

# Use context
kubectl config use-context kind-k8s-c1 >/dev/null 2>&1 || true

# Lab 03
kubectl create namespace project-c13 >/dev/null 2>&1 || true
kubectl apply -f yaml-definitions/statefulset-o3db.yaml >/dev/null 2>&1 || true

# Lab 04
kubectl apply -f yaml-definitions/lab4-service-am-i-ready.yaml >/dev/null 2>&1 || true

# Lab 07
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1 || true
helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system >/dev/null 2>&1 || true

# Lab 10
kubectl create namespace project-hamster >/dev/null 2>&1 || true

# Lab 06, 11, 12, 17
kubectl create namespace project-tiger >/dev/null 2>&1 || true

# Lab 24
kubectl create ns project-snake >/dev/null 2>&1 || true
kubectl -n project-snake run backend-0 --image=alpine/curl --labels app=backend --command -- /bin/sh -c "while true; do sleep 3600; done" >/dev/null 2>&1 || true
kubectl -n project-snake run db1-0 --image=hashicorp/http-echo --labels app=db1 --port=1111 -- --text="database one" --listen=:1111 >/dev/null 2>&1 || true
kubectl -n project-snake run db2-0 --image=hashicorp/http-echo --labels app=db2 --port=2222 -- --text="database two" --listen=:2222 >/dev/null 2>&1 || true
kubectl -n project-snake run vault-0 --image=hashicorp/http-echo --labels app=vault --port=3333 -- --text="vault secret storage" --listen=:3333 >/dev/null 2>&1 || true

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml >/dev/null 2>&1 || true
echo 'k8s-c1 cluster completed! 🚀\n'

####### Create k8s-c2 #######
echo '--------------------------'
echo '👉 creating k8s-c2 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c2 --config yaml-definitions/cluster.yaml

echo '\nPreparing k8s-c2 cluster... 🚜'

# Install vim
docker exec -it k8s-c2-control-plane bash -c "apt update -qq" 
docker exec -it k8s-c2-control-plane bash -c "apt install vim -y -qq" 

echo 'k8s-c2 cluster completed! 🚀\n'

####### Create k8s-c3 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c3 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c3 --config yaml-definitions/cluster.yaml

echo '\nPreparing k8s-c3 cluster... 🚜'

# Install vim
docker exec -it k8s-c3-worker bash -c "apt update -qq" 
docker exec -it k8s-c3-worker bash -c "apt install vim -y -qq" 

# Modify the 10-kubeadm.conf file to introduce a bug in the container
docker exec -it k8s-c3-worker bash -c "sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf" 

# Reload daemon
docker exec -it k8s-c3-worker bash -c "systemctl daemon-reload" 

# Stop and start the kubelet process
docker exec -it k8s-c3-worker bash -c "systemctl stop kubelet" 
docker exec -it k8s-c3-worker bash -c "systemctl start kubelet" 

# Lab 25 Etcd Backup
docker exec -it k8s-c3-control-plane bash -c "curl -L https://storage.googleapis.com/etcd/v3.5.17/etcd-v3.5.17-linux-amd64.tar.gz -o /tmp/etcd-v3.5.17-linux-amd64.tar.gz" 
docker exec -it k8s-c3-control-plane bash -c "mkdir /tmp/etcd-download-test" 
docker exec -it k8s-c3-control-plane bash -c "tar xzvf /tmp/etcd-v3.5.17-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1" 
docker exec -it k8s-c3-control-plane bash -c "rm -f /tmp/etcd-v3.5.17-linux-amd64.tar.gz" 
docker exec -it k8s-c3-control-plane bash -c "mv /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl" 

docker exec -it k8s-c3-control-plane bash -c "apt-get update -qq" 
docker exec -it k8s-c3-control-plane bash -c "apt-get install vim -y -qq" 

echo 'k8s-c3 cluster completed! 🚀\n'

####### Create k8s-c4 cluster #######
echo '--------------------------'
echo '👉 creating k8s-c4 cluster'
echo '--------------------------\n'

kind create cluster --name k8s-c4 --config yaml-definitions/cluster.yaml

echo '\nPreparing k8s-c4 cluster... 🚜'

# Drain the k8s-c4-worker2 node
kubectl drain k8s-c4-worker2 --ignore-daemonsets --delete-emptydir-data >/dev/null 2>&1 || true

# Delete the node
kubectl delete node k8s-c4-worker2 >/dev/null 2>&1 || true

# Reset the node
docker exec -it k8s-c4-worker2 bash -c "kubeadm reset --force" 

## Install vim on k8s-c4-control-plane
docker exec -it k8s-c4-control-plane bash -c "apt-get update -qq" 
docker exec -it k8s-c4-control-plane bash -c "apt-get install vim -y -qq" 

# Install other version
docker exec -it k8s-c4-worker2 bash -c "apt-get update -qq" 
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y apt-transport-https ca-certificates curl gpg -qq" 
docker exec -it k8s-c4-worker2 bash -c "mkdir -p -m 755 /etc/apt/keyrings" 
docker exec -it k8s-c4-worker2 bash -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" 
docker exec -it k8s-c4-worker2 bash -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list" 
docker exec -it k8s-c4-worker2 bash -c "apt-get update -qq" 
docker exec -it k8s-c4-worker2 bash -c "apt-get install -y kubelet=1.29.3-1.1 kubectl=1.29.3-1.1 -qq" 

echo 'k8s-c4 cluster completed! 🚀\n'
