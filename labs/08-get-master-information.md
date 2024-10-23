# Get Master Information - 2%

## Use Context

```shell
k config use-context kind-cka
Switched to context "kind-cka".
```

## Task Definition

- SSH into the master node with `docker exec -it cka-control-plane bash`.
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

## Connect to cka-control-plane and get kubelet processes

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/# 
```

```shell
ps aux | grep kubelet
root         563  4.6  1.6 1447956 277512 ?      Ssl  02:48  54:27 kube-apiserver --advertise-address=172.18.0.4 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --runtime-config= --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root         703  1.9  0.5 2775260 95756 ?       Ssl  02:48  23:13 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///run/containerd/containerd.sock --node-ip=172.18.0.4 --node-labels= --pod-infra-container-image=registry.k8s.io/pause:3.9 --provider-id=kind://docker/cka/cka-control-plane --runtime-cgroups=/system.slice/containerd.service
root       14149  0.0  0.0   2904  1316 pts/1    S+   22:24   0:00 grep kubelet
```

Check which components are controlled via `systemd` looking at `/etc/systemd/system` directory:

```shell
root@cka-control-plane:/# find /etc/systemd/system/ | grep kube
/etc/systemd/system/10-kubeadm.conf
/etc/systemd/system/multi-user.target.wants/kubelet.service
/etc/systemd/system/kubelet.service
/etc/systemd/system/kubelet.slice
/etc/systemd/system/kubelet.service.d
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/systemd/system/kubelet.service.d/11-kind.conf
root@cka-control-plane:/#
```

```shell
root@cka-control-plane:/# find /etc/systemd/system/ | grep etcd
```

This shows `kubelet` is controlled via `systemd`, but no other service named kube nor etcd. It seems that this cluster has been setup using `kubeadm`, so we check in the default manifests directory:

```shell
root@cka-control-plane:/# find /etc/kubernetes/manifests/
/etc/kubernetes/manifests/
/etc/kubernetes/manifests/kube-scheduler.yaml
/etc/kubernetes/manifests/etcd.yaml
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/manifests/kube-controller-manager.yaml
root@cka-control-plane:/#
```

Let's check all `Pods` running on in the `kube-system` namespace on the master node:

```shell
kubectl -n kube-system get pod -o wide | grep master
root@cka-control-plane:/# kubectl -n kube-system get pod -o wide | grep control-plane
coredns-76f75df574-k87qd                    1/1     Running   0          19h    10.244.0.4   cka-control-plane   <none>           <none>
coredns-76f75df574-tsrm6                    1/1     Running   0          19h    10.244.0.3   cka-control-plane   <none>           <none>
etcd-cka-control-plane                      1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
kindnet-f778c                               1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
kube-apiserver-cka-control-plane            1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
kube-controller-manager-cka-control-plane   1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
kube-proxy-trm87                            1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
kube-scheduler-cka-control-plane            1/1     Running   0          19h    172.18.0.4   cka-control-plane   <none>           <none>
```

We see that 4 static pods, with `-cka-control-plane` as suffix.

We also see that dns application seems to be coredns, but how is controlled?

```shell
root@cka-control-plane:/# kubectl -n kube-system get ds
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kindnet      3         3         3       3            3           kubernetes.io/os=linux   19h
kube-proxy   3         3         3       3            3           kubernetes.io/os=linux   19h
```

```shell
root@cka-control-plane:/# kubectl -n kube-system get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
coredns          2/2     2            2           19h
metrics-server   1/1     1            1           128m
```

Seems `coredns` is controlled via a `Deployment`. We can generate the file with the findings:

## Generating the file

```shell
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: pod
dns: pod coredns
```
