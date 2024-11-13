# Deployment on All Nodes - 6%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Use the Namespace called `project-tiger`.
- Create a Deployment named `deploy-important` with label `id=very-important` (the Pods should also have this label) and 3 replicas.
- It should contain two containers, the first named container1 with image `nginx:1.7.6-alpine` and the second one named container2 with image `busybox` with a sleep command.
- There should be only ever one Pod of that Deployment running on `one` worker node.
- We have two worker nodes: `k8s-c1-worker` and `k8s-c1-worker2`.
- Because the Deployment has tree replicas the result should be that on both nodes one Pod is running. The third Pod won't be scheduled, unless a new worker node will be added.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the Deployment YAML Definition

```shell
k -n project-tiger create deployment deploy-important --image=nginx:1.7.6-alpine --replicas=3 -o yaml --dry-run=client > 12.yaml
```

### Change the YAML Definition

Additional to add a second container, the important task is to prevent two containers to run in the same node. We need to add a `podAntiAffinity` rule and for the `matchExpressions` we need to add the Deployment labels.

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: kubernetes.io/hostname
      labelSelector:
        matchExpressions:
        - key: id
          operator: In
          values:
          - very-important
```

The complete YAML definition:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    id: very-important
  name: deploy-important
  namespace: project-tiger
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  strategy: {}
  template:
    metadata:
      labels:
        id: very-important
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                  - key: id
                    operator: In
                    values:
                      - very-important
      containers:
      - image: nginx:1.7.6-alpine
        name: container1
        resources: {}
      - image: kubernetes/pause
        name: container2
```

### Apply the YAML Definition

```shell
k apply -f 12.yaml
deployment.apps/deploy-important created
```

### Validate the Pods Distribution in the Cluster

```shell
k -n project-tiger get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
deploy-important-5f8df96666-4sf8v   2/2     Running   0          8s    10.244.2.5   k8s-c1-worker    <none>           <none>
deploy-important-5f8df96666-dswxg   2/2     Running   0          8s    10.244.1.4   k8s-c1-worker2   <none>           <none>
deploy-important-5f8df96666-swcvn   0/2     Pending   0          8s    <none>       <none>           <none>           <none>
```

## Clean the Environment

### Delete the Deployment

```shell
k -n project-tiger delete deploy deploy-important
deployment.apps "deploy-important" deleted
```

### Check Pods were deleted

```shell
k -n project-tiger get pod -o wide
No resources found in project-tiger namespace.
```

### Delete the Namespace

```shell
k delete ns project-tiger
namespace "project-tiger" deleted
```
</details>
