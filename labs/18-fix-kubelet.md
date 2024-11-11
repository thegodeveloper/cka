# Fix Kubelet - 8%

## Use context

```shell
kubectl config use-context kind-k8s-c3
```

## Task Definition

- Seems that `kubelet` service is not running in the `cka-worker` node.
- Fix it and confirm that cluster has node `k8s-c3-worker` available in Ready state afterwards.
- You should be able to schedule a `Pod` on cluster `cka-worker afterwards.
- Write the reason of the issue into `18-reason.txt`.

## Solution

### Validate the nodes in the cluster

```shell
k get nodes
NAME                   STATUS     ROLES           AGE     VERSION
k8s-c3-control-plane   Ready      control-plane   2m22s   v1.29.0
k8s-c3-worker          NotReady   <none>          2m      v1.29.0
k8s-c3-worker2         Ready      <none>          2m      v1.29.0
```

The node `k8s-c3-worker` is in `NotReady` state.

### Validate the kubelet status

#### Connect to the node

```shell
docker exec -it k8s-c3-worker bash
root@k8s-c3-worker:/#
```

#### Validate the kubelet status with systemctl

```shell
root@k8s-c3-worker:/# systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 11-kind.conf
     Active: activating (start-pre) since Mon 2024-11-11 17:48:48 UTC; 2ms ago
       Docs: http://kubernetes.io/docs/
Cntrl PID: 7058 (sh)
      Tasks: 1 (limit: 19159)
     Memory: 256.0K
        CPU: 0
     CGroup: /kubelet.slice/kubelet.service
             ├─7058 /bin/sh -euc if [ -f /sys/fs/cgroup/cgroup.controllers ]; then /kind/bin/create-kubelet-cgroup-v2.sh; fi
             └─7059 /bin/bash /kind/bin/create-kubelet-cgroup-v2.sh

Nov 11 17:48:48 lab18-worker systemd[1]: Starting kubelet: The Kubernetes Node Agent...
```

The `kubelet` service is not running.

Check the following output:

```shell
Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 11-kind.conf
```

This is the location of the configuration files:

#### Validate the 10-kubeadm.conf file

```shell
root@k8s-c3-worker:/# cd /etc/systemd/system/kubelet.service.d/
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# cat 10-kubeadm.conf
# https://github.com/kubernetes/kubernetes/blob/ba8fcafaf8c502a454acd86b728c857932555315/build/debs/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

Validate if the location of the `/usr/local/bin/kubelet` is correct.

#### Validate the location of the kubelet command

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# ls -l /usr/local/bin/kubelet
ls: cannot access '/usr/local/bin/kubelet': No such file or directory
```

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# which kubelet
/usr/bin/kubelet
```

Seems the configuration in `10-kubeadm.conf` is pointing to the wrong `kubelet` location.

### Fix the kubelet location

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# vim 10-kubeadm.conf 

Change /usr/local/bin/kubelet for /usr/bin/kubelet
```

#### Start the kubelet service

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# systemctl start kubelet
Warning: The unit file, source configuration file or drop-ins of kubelet.service changed on disk. Run 'systemctl daemon-reload' to reload units.
```

Follow the instructions:

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# systemctl daemon-reload --->> No output
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# 
```

Start `kubelet` service again:

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# systemctl start kubelet --->> No output
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# 
```

Validate the `kubelet` service:

```shell
root@k8s-c3-worker:/etc/systemd/system/kubelet.service.d# systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 11-kind.conf
     Active: active (running) since Mon 2024-11-11 17:58:11 UTC; 2min 5s ago
       Docs: http://kubernetes.io/docs/
    Process: 11642 ExecStartPre=/bin/sh -euc if [ -f /sys/fs/cgroup/cgroup.controllers ]; then /kind/bin/create-kubelet-cgroup-v2.sh; fi (code=exited, status=0/SUCCESS)
    Process: 11663 ExecStartPre=/bin/sh -euc if [ ! -f /sys/fs/cgroup/cgroup.controllers ] && [ ! -d /sys/fs/cgroup/systemd/kubelet ]; then mkdir -p /sys/fs/cgroup/systemd/kubelet; fi (code=exited, status=0/SUCCESS)
   Main PID: 11664 (kubelet)
      Tasks: 19 (limit: 19159)
     Memory: 27.7M
        CPU: 1.175s
     CGroup: /kubelet.slice/kubelet.service
             └─11664 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///run/containerd/containerd.sock --node-ip=172.18.0.2 --node-labels= --pod-infra-container-image=registry.k8s.io/pause:3.9 --provider-id=kind://docker/lab18/lab18-worker --runtime-cgroups=/system.slice/containerd.service

Nov 11 17:58:11 lab18-worker kubelet[11664]: I1111 17:58:11.318718   11664 kubelet_network.go:61] "Updating Pod CIDR" originalPodCIDR="" newPodCIDR="10.244.2.0/24"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.208405   11664 apiserver.go:52] "Watching apiserver"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.210322   11664 topology_manager.go:215] "Topology Admit Handler" podUID="bb9291f9-ca84-495d-8c84-014d0347521d" podNamespace="kube-system" podName="kindnet-xt7hb"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.210400   11664 topology_manager.go:215] "Topology Admit Handler" podUID="d91ab1b3-1785-4bc8-837f-b7cbe7099b8e" podNamespace="kube-system" podName="kube-proxy-tj77b"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.311629   11664 desired_state_of_world_populator.go:159] "Finished populating initial desired state of world"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.328591   11664 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/d91ab1b3-1785-4bc8-837f-b7cbe7099b8e-lib-modules\") pod \"kube-proxy-tj77b\" (UID: \"d91ab1b3-1785-4bc8-837f-b7cbe7099b8e\") " pod="kube-system/kube-proxy-tj77b"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.328672   11664 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"cni-cfg\" (UniqueName: \"kubernetes.io/host-path/bb9291f9-ca84-495d-8c84-014d0347521d-cni-cfg\") pod \"kindnet-xt7hb\" (UID: \"bb9291f9-ca84-495d-8c84-014d0347521d\") " pod="kube-system/kindnet-xt7hb"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.328689   11664 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/bb9291f9-ca84-495d-8c84-014d0347521d-xtables-lock\") pod \"kindnet-xt7hb\" (UID: \"bb9291f9-ca84-495d-8c84-014d0347521d\") " pod="kube-system/kindnet-xt7hb"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.328706   11664 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/bb9291f9-ca84-495d-8c84-014d0347521d-lib-modules\") pod \"kindnet-xt7hb\" (UID: \"bb9291f9-ca84-495d-8c84-014d0347521d\") " pod="kube-system/kindnet-xt7hb"
Nov 11 17:58:12 lab18-worker kubelet[11664]: I1111 17:58:12.328747   11664 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/d91ab1b3-1785-4bc8-837f-b7cbe7099b8e-xtables-lock\") pod \"kube-proxy-tj77b\" (UID: \"d91ab1b3-1785-4bc8-837f-b7cbe7099b8e\") " pod="kube-system/kube-proxy-tj77b"
```

Exit the node.

### Validate the Nodes

The nodes should be on `Ready` state.

```shell
k get nodes
NAME                  STATUS   ROLES           AGE   VERSION
k8s-c3-control-plane   Ready    control-plane   25m   v1.29.0
k8s-c3-worker          Ready    <none>          24m   v1.29.0
k8s-c3-worker2         Ready    <none>          24m   v1.29.0
```

### Run a Pod in the node

```shell
k run nginx --image=nginx --dry-run=client -o yaml > 18-pod.yaml
```

Add `nodeSelector:` to `18-pod.yaml` file at same level of `containers`:

Get the k8s-c3-worker node `Labels`:

```shell
k describe node k8s-c3-worker | grep Labels -A5
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=k8s-c3-worker
                    kubernetes.io/os=linux
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///run/containerd/containerd.sock
```

```shell
spec:
  nodeSelector: 
    kubernetes.io/hostname: k8s-c3-worker
  containers:
```

Apply the `18-pod.yaml` file:

```shell
k apply -f 18-pod.yaml
pod/nginx created
```

Validate the location of the pod:

```shell
k get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          66s   10.244.2.2   k8s-c3-worker   <none>           <none>
```

Pod was scheduled in the `lab18-worker` node.

### Write the reason of the issue

```shell
echo 'wrong path to kubelet binary specified in service config' > 18-reason.txt
```
