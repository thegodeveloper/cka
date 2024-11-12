# Update Kubernetes Version and Join Cluster

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

</details>
