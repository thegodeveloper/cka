# Question 14 - Find out Cluster Information - 2%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

Find out following information about the cluster `kind-cka`:
1. How many master nodes are available?
2. How many worker nodes are available?
3. What is the Service CIDR?
4. Which Networking (or CNI Plugin) is configured and where is it config file?
5. Which suffix will static pods have that run on `k8s-c1-worker`?

Write your answers into file `cluster-info.txt`, structured like this:

```shell
# cluster-info.txt
1: [ANSWER]
2: [ANSWER]
3: [ANSWER]
4: [ANSWER]
5: [ANSWER]
```

## Solution

<details>
  <summary>Show the solution</summary>

### How many master and worker nodes are available?

```shell
k get node
NAME                STATUS      ROLES           AGE    VERSION
k8s-c1-control-plane   Ready    control-plane   172m   v1.29.0
k8s-c1-worker          Ready    <none>          172m   v1.29.0
k8s-c1-worker2         Ready    <none>          172m   v1.29.0
```

We see one master and two workers.

### What is the Service CIDR?

```shell
docker exec -it k8s-c1-control-plane bash
root@k8s-c1-control-plane:/# cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep range
    - --service-cluster-ip-range=10.96.0.0/16
```

### Which Networking (or CNI Plugin) is configured and where is its config file?

```shell
root@k8s-c1-control-plane:/# find /etc/cni/net.d/
/etc/cni/net.d/
/etc/cni/net.d/10-kindnet.conflist
root@k8s-c1-control-plane:/# cat /etc/cni/net.d/10-kindnet.conflist | grep cniVersion
        "cniVersion": "0.3.1",
```

By default, the kubelet looks into `/etc/cni/net.d/` to discover the CNI plugins. This will be the same on every master and worker nodes.

### Which suffix static pods have that run on k8s-c1-worker?

`-k8s-c1-worker`

## Result

The resulting `cluster-info.txt` file could look like:

```shell
# cluster-info.txt
1: 1
2: 2
3: 10.96.0.0/16
4: kindnet, /etc/cni/net.d/10-kindnet.conflist
5: -k8s-c1-worker
```
</details>
