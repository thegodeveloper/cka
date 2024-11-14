# Question 8 - Get Master Information - 2%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- SSH into the master node with `docker exec -it k8s-c1-control-plane bash`.
- Check how the master components `kubelet`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` and `etcd` are started/installed on the master node.
- Find out the name of the DNS application and how it's started/installed on the master node.

Write your findings into file `8-master-components.txt`. The file should be structured like:

```shell
# /opt/course/8/master-components.txt
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]
```

Choices of `[TYPE]` are: `not-installed`, `process`, `static-pod`, `pod`.

## Solution

<details>
  <summary>Show the solution</summary>

### Connect to k8s-c1-control-plane and get kubelet processes

```shell
docker exec -it k8s-c1-control-plane bash
root@k8s-c1-control-plane:/# 
```

```shell
ps aux | grep kubelet
root         567  3.5  3.5 1517664 287392 ?      Ssl  16:05   2:30 kube-apiserver --advertise-address=172.18.0.3 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --runtime-config= --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root         741  1.4  1.2 2998988 98416 ?       Ssl  16:05   1:01 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///run/containerd/containerd.sock --node-ip=172.18.0.3 --node-labels= --pod-infra-container-image=registry.k8s.io/pause:3.9 --provider-id=kind://docker/k8s-c1/k8s-c1-control-plane --runtime-cgroups=/system.slice/containerd.service
root       29119  0.0  0.0   3240  1772 pts/1    S+   17:17   0:00 grep kubelet
```

Check which components are controlled via `systemd` looking at `/etc/systemd/system` directory:

```shell
root@k8s-c1-control-plane:/# find /etc/systemd/system/ | grep kube
/etc/systemd/system/10-kubeadm.conf
/etc/systemd/system/multi-user.target.wants/kubelet.service
/etc/systemd/system/kubelet.service
/etc/systemd/system/kubelet.slice
/etc/systemd/system/kubelet.service.d
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/systemd/system/kubelet.service.d/11-kind.conf
root@k8s-c1-control-plane:/#
```

```shell
root@k8s-c1-control-plane:/# find /etc/systemd/system/ | grep etcd
```

This shows `kubelet` is controlled via `systemd`, but no other service named kube nor etcd. It seems that this cluster has been setup using `kubeadm`, so we check in the default manifests directory:

```shell
root@k8s-c1-control-plane:/# find /etc/kubernetes/manifests/
/etc/kubernetes/manifests/
/etc/kubernetes/manifests/kube-scheduler.yaml
/etc/kubernetes/manifests/etcd.yaml
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/manifests/kube-controller-manager.yaml
root@k8s-c1-control-plane:/#
```

Let's check all `Pods` running on in the `kube-system` namespace on the master node:

```shell
root@k8s-c1-control-plane:/# kubectl -n kube-system get pod -o wide | grep control-plane
calico-node-xb7vz                              1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
coredns-76f75df574-qtrrz                       1/1     Running   0          74m   10.244.0.2   k8s-c1-control-plane   <none>           <none>
coredns-76f75df574-xp5kr                       1/1     Running   0          74m   10.244.0.3   k8s-c1-control-plane   <none>           <none>
etcd-k8s-c1-control-plane                      1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
kindnet-7pl7v                                  1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
kube-apiserver-k8s-c1-control-plane            1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
kube-controller-manager-k8s-c1-control-plane   1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
kube-proxy-kfbfd                               1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
kube-scheduler-k8s-c1-control-plane            1/1     Running   0          74m   172.18.0.3   k8s-c1-control-plane   <none>           <none>
```

We see that 4 static pods, with `-k8s-c1-control-plane` as suffix.

We also see that dns application seems to be coredns, but how is controlled?

```shell
root@k8s-c1-control-plane:/# kubectl -n kube-system get ds
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kindnet      3         3         3       3            3           kubernetes.io/os=linux   19h
kube-proxy   3         3         3       3            3           kubernetes.io/os=linux   19h
```

```shell
root@k8s-c1-control-plane:/# kubectl -n kube-system get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
coredns          2/2     2            2           19h
metrics-server   1/1     1            1           128m
```

Seems `coredns` is controlled via a `Deployment`. We can generate the file with the findings:

### Generating the file

```shell
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: pod
dns: pod coredns
```
</details>
