# Nodes

## Review the cluster nodes

```shell
k get no -o wide                                                                                                                                                             ─╯
NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
cka-control-plane   Ready    control-plane   24m   v1.29.0   172.18.0.3    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
cka-worker          Ready    <none>          24m   v1.29.0   172.18.0.2    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
cka-worker2         Ready    <none>          24m   v1.29.0   172.18.0.4    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
```

## Access the control plane node

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/#
```

## List the containers running inside the control plane

```shell
crictl ps

CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
fee5b8d4118d0       eec7db0a07d0d       27 minutes ago      Running             local-path-provisioner    0                   89214ff0e4d1a       local-path-provisioner-6f8956fb48-l99fw
554306a97d086       2437cf7621777       27 minutes ago      Running             coredns                   0                   132c3f2b8b1bf       coredns-76f75df574-jwxzs
02dbe8d990527       2437cf7621777       27 minutes ago      Running             coredns                   0                   14c4e92958b90       coredns-76f75df574-wfj7v
c6e22cb5038e4       b18bf71b941ba       27 minutes ago      Running             kindnet-cni               0                   7261bcd8e839c       kindnet-rw7vn
66b3aad6286db       0c3491790de4f       27 minutes ago      Running             kube-proxy                0                   3973b004c04ce       kube-proxy-slpjz
c8601b13d869a       79f8d13ae8b88       28 minutes ago      Running             etcd                      0                   e365d21b49bc6       etcd-cka-control-plane
9d5ebea96986b       d76e6545057e5       28 minutes ago      Running             kube-controller-manager   0                   ba1c508972831       kube-controller-manager-cka-control-plane
e2257c21723b9       0086b4e50ff2e       28 minutes ago      Running             kube-apiserver            0                   980f821112b81       kube-apiserver-cka-control-plane
368a455dc30ee       19c8641dee5a9       28 minutes ago      Running             kube-scheduler            0                   69cb845572a21       kube-scheduler-cka-control-plane
root@cka-control-plane:/#
```

- The `local-path-provisioner` is used for persistent storage in our cluster
- `coredns` is used for resolving names to IP addresses in our cluster (DNS)
- `kindnet-cni` is used for pod-to-pod communication in our cluster

## Get pods that are running in worker nodes

```shell
kubectl get nodes --selector=kubernetes.io/hostname | grep 'cka-worker'

cka-worker          Ready    <none>          37m   v1.29.0
cka-worker2         Ready    <none>          37m   v1.29.0
```

## Get the container runtime in the nodes

```shell
root@cka-control-plane:/# kubectl get no -o wide
NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
cka-control-plane   Ready    control-plane   39m   v1.29.0   172.18.0.3    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
cka-worker          Ready    <none>          39m   v1.29.0   172.18.0.2    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
cka-worker2         Ready    <none>          39m   v1.29.0   172.18.0.4    <none>        Debian GNU/Linux 11 (bullseye)   6.6.32-linuxkit   containerd://1.7.1
```
