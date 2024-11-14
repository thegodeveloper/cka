# Question 20 - Update Kubernetes Version and Join Cluster - 10%

## Use context

```shell
kubectl config use-context kind-k8s-c4
```

## Task Definition

- Cluster node `k8s-c4-worker2` is running an older Kubernetes version and is not even part of the cluster.
- Update Kubernetes on that node to the exact version that's running on `k8s-c4-control-plane`.
- Add this node to the cluster. Use `kubeadm` for this task.

## Solution

<details>
  <summary>Show the solution</summary>

## Get cluster nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c4-control-plane   Ready    control-plane   35m   v1.29.0
k8s-c4-worker          Ready    <none>          35m   v1.29.0
```

Master node seems to be running Kubernetes `1.29.0` and `k8s-c4-worker2` is not yet part of the cluster.

## Get k8s-c4-worker2 node version

```shell
docker exec -it k8s-c4-worker2 bash

root@k8s-c4-worker2:/# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"29", GitVersion:"v1.29.0", GitCommit:"3f7a50f38688eb332e2a1b013678c6435d539ae6", GitTreeState:"clean", BuildDate:"2023-12-14T19:18:17Z", GoVersion:"go1.21.5", Compiler:"gc", Platform:"linux/amd64"}

root@k8s-c4-worker2:/# kubectl version
Client Version: v1.29.3
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
The connection to the server localhost:8080 was refused - did you specify the right host or port?

root@k8s-c4-worker2:/# kubelet --version
Kubernetes v1.29.3
```

## Validate the node upgrade

```shell
docker exec -it k8s-c4-worker2 bash

root@k8s-c4-worker2:/# kubeadm upgrade node
couldn't create a Kubernetes client from file "/etc/kubernetes/kubelet.conf": failed to load admin kubeconfig: open /etc/kubernetes/kubelet.conf: no such file or directory
To see the stack trace of this error execute with --v=5 or higher
```

This is usually the proper command to upgrade a node. But this error means that this node was never initialized. Continue with `kubelet` and `kubectl`.

## Validate the versions available

```shell
root@k8s-c4-worker2:/# apt-cache madison kubeadm
   kubeadm | 1.29.10-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.9-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.8-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.4-2.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
   kubeadm | 1.29.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.29/deb  Packages
```

## Install the target version

```shell
root@k8s-c4-worker2:/# apt-get install kubectl=1.29.0-1.1 kubelet=1.29.0-1.1 -y --allow-downgrades
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages will be DOWNGRADED:
  kubectl kubelet
0 upgraded, 0 newly installed, 2 downgraded, 0 to remove and 42 not upgraded.
Need to get 30.3 MB of archives.
After this operation, 205 kB disk space will be freed.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.29/deb  kubectl 1.29.0-1.1 [10.5 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.29/deb  kubelet 1.29.0-1.1 [19.8 MB]
Fetched 30.3 MB in 5s (5508 kB/s)  
debconf: delaying package configuration, since apt-utils is not installed
dpkg: warning: downgrading kubectl from 1.29.3-1.1 to 1.29.0-1.1
(Reading database ... 9404 files and directories currently installed.)
Preparing to unpack .../kubectl_1.29.0-1.1_amd64.deb ...
Unpacking kubectl (1.29.0-1.1) over (1.29.3-1.1) ...
dpkg: warning: downgrading kubelet from 1.29.3-1.1 to 1.29.0-1.1
Preparing to unpack .../kubelet_1.29.0-1.1_amd64.deb ...
Unpacking kubelet (1.29.0-1.1) over (1.29.3-1.1) ...
Setting up kubectl (1.29.0-1.1) ...
Setting up kubelet (1.29.0-1.1) ...
```

## Validate kubelet and kubectl versions

```shell
root@k8s-c4-worker2:/# kubectl version
Client Version: v1.29.0
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
The connection to the server localhost:8080 was refused - did you specify the right host or port?
root@k8s-c4-worker2:/# kubelet --version
Kubernetes v1.29.0
```

## Restart the kubelet service

```shell
root@k8s-c4-worker2:/# systemctl restart kubelet
root@k8s-c4-worker2:/# service kubelet status
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 11-kind.conf
     Active: inactive (dead)
  Condition: start condition failed at Tue 2024-11-12 14:53:43 UTC; 15s ago
             └─ ConditionPathExists=/var/lib/kubelet/config.yaml was not met
       Docs: http://kubernetes.io/docs/

Nov 12 14:39:01 k8s-c4-worker2 systemd[1]: Condition check resulted in kubelet: The Kubernetes Node Agent being skipped.
Nov 12 14:53:43 k8s-c4-worker2 systemd[1]: Condition check resulted in kubelet: The Kubernetes Node Agent being skipped.
```

Ignore the errors for now.

## Generate a join command from the master node

```shell
docker exec -it k8s-c4-control-plane bash

root@k8s-c4-control-plane:/# kubeadm token create --print-join-command
kubeadm join k8s-c4-control-plane:6443 --token ux9gw8.p94yznuecybo1001 --discovery-token-ca-cert-hash sha256:2704aa34d2489eb92be0378ffcdd9aee6ae3fde334dd4d16ea06d5d7139c59cd

root@k8s-c4-control-plane:/# kubeadm token list
TOKEN                     TTL         EXPIRES                USAGES                   DESCRIPTION                                                EXTRA GROUPS
abcdef.0123456789abcdef   23h         2024-11-13T14:09:10Z   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token
ux9gw8.p94yznuecybo1001   23h         2024-11-13T14:56:19Z   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token
```

## Connect to k8s-c4-worker2 and run the join command

```shell
docker exec -it k8s-c4-worker2 bash

kubeadm join k8s-c4-control-plane:6443 --token ux9gw8.p94yznuecybo1001 --discovery-token-ca-cert-hash sha256:2704aa34d2489eb92be0378ffcdd9aee6ae3fde334dd4d16ea06d5d7139c59cd

[preflight] Running pre-flight checks
	[WARNING Swap]: swap is supported for cgroup v2 only; the NodeSwap feature gate of the kubelet is beta but disabled by default
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

## Validate the kubelet status

```shell
root@k8s-c4-worker2:/# service kubelet status
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 11-kind.conf
     Active: active (running) since Tue 2024-11-12 14:58:49 UTC; 1min 11s ago
       Docs: http://kubernetes.io/docs/
    Process: 435 ExecStartPre=/bin/sh -euc if [ -f /sys/fs/cgroup/cgroup.controllers ]; then /kind/bin/create-kubelet-cgroup-v2.sh; fi (code=exited, status=0/SUCCESS)
    Process: 443 ExecStartPre=/bin/sh -euc if [ ! -f /sys/fs/cgroup/cgroup.controllers ] && [ ! -d /sys/fs/cgroup/systemd/kubelet ]; then mkdir -p /sys/fs/cgroup/systemd/kubelet; fi (code=exited, status=0/SUCCESS)
   Main PID: 444 (kubelet)
      Tasks: 23 (limit: 9398)
     Memory: 31.7M
        CPU: 801ms
     CGroup: /kubelet.slice/kubelet.service
             └─444 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9 --runtime-cgroups=/system.slice/containerd.service

Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228013     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/5d560e1a-8e81-4625-b078-0330717e2285-xtables-lock\") pod \"kindnet-bp5hf\" (UID: \"5d560e1a-8e81-4625-b078-0330717e2285\") " pod="kube-system/kindnet-bp5hf"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228052     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/5d560e1a-8e81-4625-b078-0330717e2285-lib-modules\") pod \"kindnet-bp5hf\" (UID: \"5d560e1a-8e81-4625-b078-0330717e2285\") " pod="kube-system/kindnet-bp5hf"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228079     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-svlpm\" (UniqueName: \"kubernetes.io/projected/5d560e1a-8e81-4625-b078-0330717e2285-kube-api-access-svlpm\") pod \"kindnet-bp5hf\" (UID: \"5d560e1a-8e81-4625-b078-0330717e2285\") " pod="kube-system/kindnet-bp5hf"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228101     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-proxy\" (UniqueName: \"kubernetes.io/configmap/118cbb2f-151b-41f1-a8ef-13bb0af24835-kube-proxy\") pod \"kube-proxy-zfrkn\" (UID: \"118cbb2f-151b-41f1-a8ef-13bb0af24835\") " pod="kube-system/kube-proxy-zfrkn"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228122     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/118cbb2f-151b-41f1-a8ef-13bb0af24835-xtables-lock\") pod \"kube-proxy-zfrkn\" (UID: \"118cbb2f-151b-41f1-a8ef-13bb0af24835\") " pod="kube-system/kube-proxy-zfrkn"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228146     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/118cbb2f-151b-41f1-a8ef-13bb0af24835-lib-modules\") pod \"kube-proxy-zfrkn\" (UID: \"118cbb2f-151b-41f1-a8ef-13bb0af24835\") " pod="kube-system/kube-proxy-zfrkn"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228166     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-fj58d\" (UniqueName: \"kubernetes.io/projected/118cbb2f-151b-41f1-a8ef-13bb0af24835-kube-api-access-fj58d\") pod \"kube-proxy-zfrkn\" (UID: \"118cbb2f-151b-41f1-a8ef-13bb0af24835\") " pod="kube-system/kube-proxy-zfrkn"
Nov 12 14:58:50 k8s-c4-worker2 kubelet[444]: I1112 14:58:50.228186     444 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"cni-cfg\" (UniqueName: \"kubernetes.io/host-path/5d560e1a-8e81-4625-b078-0330717e2285-cni-cfg\") pod \"kindnet-bp5hf\" (UID: \"5d560e1a-8e81-4625-b078-0330717e2285\") " pod="kube-system/kindnet-bp5hf"
Nov 12 14:58:51 k8s-c4-worker2 kubelet[444]: I1112 14:58:51.137151     444 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="kube-system/kube-proxy-zfrkn" podStartSLOduration=2.137108734 podStartE2EDuration="2.137108734s" podCreationTimestamp="2024-11-12 14:58:49 +0000 UTC" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2024-11-12 14:58:51.137108633 +0000 UTC m=+2.062077569" watchObservedRunningTime="2024-11-12 14:58:51.137108734 +0000 UTC m=+2.062077659"
Nov 12 14:58:51 k8s-c4-worker2 kubelet[444]: I1112 14:58:51.986379     444 kubelet_node_status.go:497] "Fast updating node status as it just became ready"
```

## Validate the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE     VERSION
k8s-c4-control-plane   Ready    control-plane   52m     v1.29.0
k8s-c4-worker          Ready    <none>          51m     v1.29.0
k8s-c4-worker2         Ready    <none>          2m18s   v1.29.0
```

</details>
