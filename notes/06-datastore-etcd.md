# Datastore etcd

## Connect to the cluster

```shell
docker exec -it cka-control-plane bash
```

## Install etcdctl

```shell
apt update && apt install -y etcd-client
```

## Set to version 3

```shell
export ETCDCTL_API=3
```

## Get the etcdctl version

```shell
etcdctl version
etcdctl version: 3.3.25
API version: 3.3
```

## Create a pod

```shell
root@cka-control-plane:/# kubectl run nginx --image=nginx --restart=Never
pod/nginx created

root@cka-control-plane:/# kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          7s
```

## Create a etcd snapshotdb

```shell
etcdctl snapshot save snapshotdb --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --cert /etc/kubernetes/pki/etcd/server.crt \
  --key /etc/kubernetes/pki/etcd/server.key

2024-07-19 23:13:03.174303 I | clientv3: opened snapshot stream; downloading
2024-07-19 23:13:03.186013 I | clientv3: completed snapshot read; closing
Snapshot saved at snapshotdb
```

### Validate the etcd snapshot

```shell
root@cka-control-plane:/# ls | grep snapshotdb
snapshotdb
```

#### Check if there is data in the snapshotdb

```shell
root@cka-control-plane:/# etcdctl snapshot status snapshotdb --write-out=table
+--------+----------+------------+------------+
|  HASH  | REVISION | TOTAL KEYS | TOTAL SIZE |
+--------+----------+------------+------------+
| e0d214 |     6752 |       1320 |     2.1 MB |
+--------+----------+------------+------------+
```

#### Delete the pod

```shell
root@cka-control-plane:/# kubectl delete pod nginx
pod "nginx" deleted
```

## Restore a etcd snapshot

### Restore the snapshot

```shell
root@cka-control-plane:/# etcdctl snapshot restore snapshotdb --data-dir /var/lib/etcd-restore
2024-07-19 23:44:53.834742 I | mvcc: restore compact to 8162
2024-07-19 23:44:53.839081 I | etcdserver/membership: added member 8e9e05c52164694d [http://localhost:2380] to cluster cdf818194e3a8c32
```

### Install vim

```shell
apt update && apt install vim
```

### Change the location where Kubernetes looks for the etcd data

This can be changed in the YAML specification for the API server, which will always be located on the control plane node in the `/etc/kubernetes/manifest/` directory.
Open the file `/etc/kubernetes/manifests/etcd.yaml` and scroll down to the very bottom and change the path for the volume from `/etc/lib/etcd/` to `/etc/lib/etcd-restore`:

```shell
vim /etc/kubernetes/manifests/etcd.yaml
```

### Validate the etcd restore

It takes sometime to get ready

```shell
root@cka-control-plane:/# kubectl get nodes
NAME                STATUS   ROLES           AGE    VERSION
cka-control-plane   Ready    control-plane   115m   v1.29.0
cka-worker          Ready    <none>          115m   v1.29.0
cka-worker2         Ready    <none>          115m   v1.29.0

root@cka-control-plane:/# kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          26m
```