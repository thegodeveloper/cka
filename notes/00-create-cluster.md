# Kind Cluster

## Install kind in macOS

Install Kind in macOS using `brew`.

```shell
brew install kind
```

## Create a Single Node

```shell
kind create cluster --name cka --config yaml-definitions/cluster2.yaml
```

### List the Nodes

```shell
k get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   22s   v1.29.0
```

## Create a Cluster with 3 Nodes

This is the cluster we are going to use in almost all sections of the labs.

```shell
kind create cluster --name cka --config yaml-definitions/cluster.yaml
```

### Get the nodes

```shell
k get nodes                                                                                                                                                                                        ─╯
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   36s   v1.29.1
cka-worker          Ready    <none>          13s   v1.29.1
cka-worker2         Ready    <none>          18s   v1.29.1
```

### View running Pods in the kube-system namespace

```shell
root@cka-control-plane:/# kubectl get po -n kube-system
NAME                                        READY   STATUS    RESTARTS   AGE
coredns-7db6d8ff4d-c9z5d                    1/1     Running   0          2m21s
coredns-7db6d8ff4d-vdnj5                    1/1     Running   0          2m21s
etcd-cka-control-plane                      1/1     Running   0          2m37s
kindnet-mdjtd                               1/1     Running   0          2m19s
kindnet-n6dhh                               1/1     Running   0          2m21s
kindnet-r2r6m                               1/1     Running   0          2m19s
kube-apiserver-cka-control-plane            1/1     Running   0          2m37s
kube-controller-manager-cka-control-plane   1/1     Running   0          2m37s
kube-proxy-8gmzk                            1/1     Running   0          2m21s
kube-proxy-q5xbj                            1/1     Running   0          2m19s
kube-proxy-sr7f8                            1/1     Running   0          2m19s
kube-scheduler-cka-control-plane            1/1     Running   0          2m37s
```

## Create a HA Cluster

```shell
kind create cluster --name cka-ha --config yaml-definitions/ha-cluster-one.yaml
```

## Kind Commands

### List Clusters

```shell
kind get clusters
cka
```

### List the Nodes in a Cluster

```shell
kind get nodes --name cka
cka-control-plane
```

### Delete a Cluster

```shell
kind delete cluster --name cka
Deleting cluster "cka" ...
Deleted nodes: ["cka-control-plane"]
```

## Connect to a Kind Docker Control-Plane Container

```shell
docker exec -it cka-control-plane bash                                                                                                                                                             ─╯
root@cka-control-plane:/#
```

## Connect to a Kind Docker Worker Container

```shell
docker exec -it cka-worker bash                                                                                                                                                                    ─╯
root@cka-worker:/#
```
