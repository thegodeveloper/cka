# Question 38 - Cordon and Node - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Create a new Deployment named `web` in `sales` namespace.
- Use the `gcr.io/google-containers/nginx` image with `3` replicas.
- Ensure that no Pods are scheduled on the node `k8s-c2-worker2`.

## Solution

<details>
  <summary>Show the solution</summary>

### List the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE    VERSION
k8s-c2-control-plane   Ready    control-plane   123m   v1.29.0
k8s-c2-worker          Ready    <none>          122m   v1.29.0
k8s-c2-worker2         Ready    <none>          122m   v1.29.0
```

### Change the status of the node k8s-c2-worker2

```shell
k cordon k8s-c2-worker2
node/k8s-c2-worker2 cordoned
```

### List the nodes

```shell
k get nodes
AME                   STATUS                     ROLES           AGE    VERSION
k8s-c2-control-plane   Ready                      control-plane   125m   v1.29.0
k8s-c2-worker          Ready                      <none>          124m   v1.29.0
k8s-c2-worker2         Ready,SchedulingDisabled   <none>          125m   v1.29.0
```

The node `k8s-c2-worker2` should have `Ready,SchedulingDisabled` state.

### Create the Deployment

```shell
k -n sales create deploy web --image=gcr.io/google-containers/nginx --replicas=3
deployment.apps/web created
```

### Check the Deployment

```shell
k -n sales get deploy
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
web    3/3     3            3           99s
```

### Check the location of the Pods in the cluster

```shell
k -n sales get pod -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP           NODE            NOMINATED NODE   READINESS GATES
web-75f69d8cc9-58qj5   1/1     Running   0          2m12s   10.244.2.2   k8s-c2-worker   <none>           <none>
web-75f69d8cc9-pbvb8   1/1     Running   0          2m12s   10.244.2.3   k8s-c2-worker   <none>           <none>
web-75f69d8cc9-rqgln   1/1     Running   0          2m12s   10.244.2.4   k8s-c2-worker   <none>           <none>
```

### Uncordon the node k8s-c2-worker2

```shell
k uncordon k8s-c2-worker2
node/k8s-c2-worker2 uncordoned
```

### List the node

```shell
k get nodes
NAME                   STATUS   ROLES           AGE    VERSION
k8s-c2-control-plane   Ready    control-plane   139m   v1.29.0
k8s-c2-worker          Ready    <none>          138m   v1.29.0
k8s-c2-worker2         Ready    <none>          138m   v1.29.0
```

</details>