# Question 30 - Schedule a Pod in a Node - 2%

## Use context

```shell
kubectl config use kind-k8s-c5
```

## Task Definition

- Create a Kubernetes Pod name `my-busybox` with the `busybox:1.31.1` image.
- The Pod should run a `sleep` command for `4800` seconds.
- Verify the node is running in `k8s-c5-worker2` node.

## Solution

<details>
  <summary>Show the solution</summary>

### Create a Pod

```shell
k run my-busybox --image=busybox:1.37.0 --command sleep 48000
pod/my-busybox created
```

### Check the Pod

```shell
k get pod my-busybox
NAME         READY   STATUS    RESTARTS   AGE
my-busybox   0/1     Pending   0          6s
```

### Describe the Pod

```shell
k describe pod my-busybox
Name:             my-busybox
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           run=my-busybox
Annotations:      <none>
Status:           Pending
IP:
IPs:              <none>
Containers:
  my-busybox:
    Image:      busybox:1.31.1
    Port:       <none>
    Host Port:  <none>
    Command:
      sleep
      48000
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jz7tb (ro)
Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  kube-api-access-jz7tb:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  33s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 1 node(s) had untolerated taint {node-role.kubernetes.io/node: }, 1 node(s) were unschedulable. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
```

According to the `Warning` message in the `describe` of the Pod, Scheduler is unable to run the Pod.

### Check the Nodes

In the `Warning`, it said that the first two nodes have tolerations that this Pod doesn't have a taint for, and the question instructs us to deploy the Pod in the `k8s-c5-worker2` node. This node has the `SchedulingDisabled` status, it is possible that the node was cordoned.

```shell
k get nodes
NAME                   STATUS                     ROLES           AGE     VERSION
k8s-c5-control-plane   Ready                      control-plane   7m6s    v1.29.0
k8s-c5-worker          Ready                      <none>          6m43s   v1.29.0
k8s-c5-worker2         Ready,SchedulingDisabled   <none>          6m42s   v1.29.0
```
### Try to uncordon the node

```shell
k uncordon k8s-c5-worker2
node/k8s-c5-worker2 uncordoned
```

### Check the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c5-control-plane   Ready    control-plane   11m   v1.29.0
k8s-c5-worker          Ready    <none>          10m   v1.29.0
k8s-c5-worker2         Ready    <none>          10m   v1.29.0
```

Nodes are on ready state.

### Check the Pod

```shell
k get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE    IP           NODE             NOMINATED NODE   READINESS GATES
my-busybox   1/1     Running   0          2m3s   10.244.2.3   k8s-c5-worker2   <none>           <none>
```



</details>