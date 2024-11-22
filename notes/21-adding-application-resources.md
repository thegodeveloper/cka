# Adding Application Resources

- During Kubernetes creation, `kubeadm` creates an initial bootstrap token with a 24-hour TTL.
- We can create additional tokens on demand.
- We can see the bootstrap token mechanism enabled in the kind Kubernetes cluster in the `/etc/kubernetes/manifests/kube-apiserver.yaml` file.

## Create Kind cluster

Follow the instructions to create cluster in [Create Cluster](00-create-cluster.md).

### Identify the Kubernetes API Server Configuration

```shell
cd /etc/kubernetes/manifests/
ls | grep apiserver kube-apiserver.yaml
```

Identify in the configuration the following section:

```yaml
containers:
  - commands:
      - ...
      - --enable-bootstrap-token-auth=true
```

- This setting allows you to add a node via an authentication token.
- `Bootstrap tokens` are essentially bearer tokens used when creating new clusters or joining new nodes to an existing cluster.
- These tokens were primarily built for `kubeadm` but can also be used in other scenarios without kubeadm, such as with third-party applications.
- A `bootstrap token` works much like a `Service Account` token in that the token allows the third-party application to authenticate with the `Kubernetes API` and communicate with objects inside of a cluster.

### Generate a token join command

#### Validate current cluster

```shell
kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   13m   v1.29.0
cka-worker          Ready    <none>          13m   v1.29.0
cka-worker2         Ready    <none>          13m   v1.29.0
```

#### Connect to the cluster

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/#
```

#### Generate the join token

```shell
kubeadm token create --print-join-command
kubeadm join cka-control-plane:6443 --token jybmm9.cwytkr9romnfg40v --discovery-token-ca-cert-hash sha256:08da489525c8d78bf766b57340e6542acd1f6a361a29a6052b6db6fa3bdb21a3
```

## Create a temporal cluster

```shell
kind create cluster --name cka-temp --config yaml-definitions/cluster2.yaml
```

### Validate the new cluster

```shell
kubectl get nodes
NAME                     STATUS   ROLES           AGE   VERSION
cka-temp-control-plane   Ready    control-plane   82s   v1.29.0
cka-temp-worker          Ready    <none>          60s   v1.29.0
```

### Delete the worker node

```shell
kubectl delete node cka-temp-worker
node "cka-temp-worker" deleted
```

### Validate the cluster state

```shell
kubectl get nodes
NAME                     STATUS   ROLES           AGE     VERSION
cka-temp-control-plane   Ready    control-plane   2m34s   v1.29.0
```

Even though we deleted `cka-temp-worker` node, the node is still running and can be accessed from outside of Kubernetes.

### Connect to the deleted node

```shell
docker exec -it cka-temp-worker bash
root@cka-temp-worker:/#
```

### Reset the node

```shell
kubeadm reset
W0902 12:30:43.309731     834 preflight.go:56] [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
W0902 12:30:59.217275     834 removeetcdmember.go:106] [reset] No kubeadm config, using etcd pod spec to get data directory
[reset] Deleted contents of the etcd data directory: /var/lib/etcd
[reset] Stopping the kubelet service
[reset] Unmounting mounted directories in "/var/lib/kubelet"
[reset] Deleting contents of directories: [/etc/kubernetes/manifests /var/lib/kubelet /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/super-admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]

The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```

### Join the node

```shell
docker exec -it cka-temp-worker bash
root@cka-temp-worker:/# kubeadm join cka-control-plane:6443 --token jybmm9.cwytkr9romnfg40v --discovery-token-ca-cert-hash sha256:08da489525c8d78bf766b57340e6542acd1f6a361a29a6052b6db6fa3bdb21a3
[preflight] Running pre-flight checks
        [WARNING Swap]: swap is supported for cgroup v2 only; the NodeSwap feature gate of the kubelet is beta but disabled by default
        [WARNING FileExisting-socat]: socat not found in system path
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

### Validate the cluster

```shell
kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   17m   v1.29.0
cka-temp-worker     Ready    <none>          60s   v1.29.0
cka-worker          Ready    <none>          17m   v1.29.0
cka-worker2         Ready    <none>          17m   v1.29.0
```

## Clean the environment

### Delete the kind-cka-temp cluster

```shell
kind delete cluster --name kind-cka-temp
Deleting cluster "kind-cka-temp" ...
```

### Delete the kind-cka cluster

```shell
kind delete cluster --name kind-cka
Deleting cluster "kind-cka" ...
```
