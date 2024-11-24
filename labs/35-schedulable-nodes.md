# Question 35 - Schedulable Nodes - 1%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Find the schedulable nodes in the cluster and save the name and count into the below file.
- nodes.txt

**Format of nodex.txt file:**
Node_Names=[] # list of schedulable nodes names, comma separated
Node_Count=   # Number of schedulable nodes

## Solution

<details>
  <summary>Show the solution</summary>

### Find the available nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c1-control-plane   Ready    control-plane   36m   v1.29.0
k8s-c1-worker          Ready    <none>          36m   v1.29.0
k8s-c1-worker2         Ready    <none>          36m   v1.29.0
```

### Validate the nodes taints

```shell
k get nodes -o jsonpath='{.items[*].spec.taints}'
[{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane"}]
```

This means that the `k8s-c1-control-plane` has a `taint` applied to it and is not an schedulable node. So, the others are.

### Create the file nodes.txt

The content of the file should be the following:

```text
Node_Names=[k8s-c1-worker,k8s-c1-worker2]
Node_Count=2
```

</details>