# Question 39 - Drain a Node - 6%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Mark the worker node named `k8s-c2-worker2` an unschedulable and reschedule all the Pods running on it.

## Solution

<details>
  <summary>Show the solution</summary>

### List the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE    VERSION
k8s-c2-control-plane   Ready    control-plane   159m   v1.29.0
k8s-c2-worker          Ready    <none>          158m   v1.29.0
k8s-c2-worker2         Ready    <none>          158m   v1.29.0
```

### List the pods running in the worker node k8s-c2-worker2

```shell
k get pod --all-namespaces
NAMESPACE            NAME                                           READY   STATUS    RESTARTS   AGE    IP           NODE                   NOMINATED NODE   READINESS GATES
default              docs-app-5f78c98b7b-56rpj                      1/1     Running   0          4m8s   10.244.1.3   k8s-c2-worker2         <none>           <none>
default              docs-app-5f78c98b7b-b7rhm                      1/1     Running   0          4m8s   10.244.1.4   k8s-c2-worker2         <none>           <none>
default              docs-app-5f78c98b7b-c7wtn                      1/1     Running   0          4m8s   10.244.1.2   k8s-c2-worker2         <none>           <none>
kube-system          coredns-76f75df574-7vgcd                       1/1     Running   0          160m   10.244.0.4   k8s-c2-control-plane   <none>           <none>
kube-system          coredns-76f75df574-tn7gq                       1/1     Running   0          160m   10.244.0.3   k8s-c2-control-plane   <none>           <none>
kube-system          etcd-k8s-c2-control-plane                      1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
kube-system          kindnet-nv7vk                                  1/1     Running   0          160m   172.18.0.7   k8s-c2-worker2         <none>           <none>
kube-system          kindnet-pc8jg                                  1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
kube-system          kindnet-r694h                                  1/1     Running   0          160m   172.18.0.5   k8s-c2-worker          <none>           <none>
kube-system          kube-apiserver-k8s-c2-control-plane            1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
kube-system          kube-controller-manager-k8s-c2-control-plane   1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
kube-system          kube-proxy-sjw4j                               1/1     Running   0          160m   172.18.0.7   k8s-c2-worker2         <none>           <none>
kube-system          kube-proxy-xhjrg                               1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
kube-system          kube-proxy-z8fn5                               1/1     Running   0          160m   172.18.0.5   k8s-c2-worker          <none>           <none>
kube-system          kube-scheduler-k8s-c2-control-plane            1/1     Running   0          160m   172.18.0.6   k8s-c2-control-plane   <none>           <none>
local-path-storage   local-path-provisioner-6f8956fb48-52nwq        1/1     Running   0          160m   10.244.0.2   k8s-c2-control-plane   <none>           <none>
```

- You could see more pods running in the cluster if you have answered some questions.
- There are several system pods running in the cluster, the important ones are the ones in default namespace that start with `docs-app`.

### Drain the node k8s-c2-worker2

````shell
k cordon k8s-c2-worker2
node/k8s-c2-worker2 cordoned
````

### List the nodes

```shell
k get nodes
NAME                   STATUS                     ROLES           AGE    VERSION
k8s-c2-control-plane   Ready                      control-plane   165m   v1.29.0
k8s-c2-worker          Ready                      <none>          164m   v1.29.0
k8s-c2-worker2         Ready,SchedulingDisabled   <none>          164m   v1.29.0
```

### List the pods

```shell
k get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
docs-app-5f78c98b7b-56rpj   1/1     Running   0          9m14s   10.244.1.3   k8s-c2-worker2   <none>           <none>
docs-app-5f78c98b7b-b7rhm   1/1     Running   0          9m14s   10.244.1.4   k8s-c2-worker2   <none>           <none>
docs-app-5f78c98b7b-c7wtn   1/1     Running   0          9m14s   10.244.1.2   k8s-c2-worker2   <none>           <none>
```

Pods are still in the `k8s-c2-worker2` node.

### Drain the node

- Go to the documentation and search for `drain` command.
- Select `Safely Drain a Node` link.

```shell
kubectl drain --ignore-daemonsets k8s-c2-worker2
ode/k8s-c2-worker2 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-nv7vk, kube-system/kube-proxy-sjw4j
evicting pod default/docs-app-5f78c98b7b-c7wtn
evicting pod default/docs-app-5f78c98b7b-56rpj
evicting pod default/docs-app-5f78c98b7b-b7rhm
pod/docs-app-5f78c98b7b-c7wtn evicted
pod/docs-app-5f78c98b7b-56rpj evicted
pod/docs-app-5f78c98b7b-b7rhm evicted
node/k8s-c2-worker2 drained
```

### List the pods

```shell
k get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
docs-app-5f78c98b7b-5hnv8   1/1     Running   0          39s   10.244.2.6   k8s-c2-worker   <none>           <none>
docs-app-5f78c98b7b-lhhmb   1/1     Running   0          39s   10.244.2.7   k8s-c2-worker   <none>           <none>
docs-app-5f78c98b7b-vscfl   1/1     Running   0          39s   10.244.2.5   k8s-c2-worker   <none>           <none>
```

- The Pods were moved to the `k8s-c2-worker` node and are in `Running` state.

### Uncordon the node

```shell
k uncordon k8s-c2-worker2
node/k8s-c2-worker2 uncordoned
```

### List the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE    VERSION
k8s-c2-control-plane   Ready    control-plane   171m   v1.29.0
k8s-c2-worker          Ready    <none>          170m   v1.29.0
k8s-c2-worker2         Ready    <none>          170m   v1.29.0
```

### List the Pods

```shell
k get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE            NOMINATED NODE   READINESS GATES
docs-app-5f78c98b7b-5hnv8   1/1     Running   0          2m59s   10.244.2.6   k8s-c2-worker   <none>           <none>
docs-app-5f78c98b7b-lhhmb   1/1     Running   0          2m59s   10.244.2.7   k8s-c2-worker   <none>           <none>
docs-app-5f78c98b7b-vscfl   1/1     Running   0          2m59s   10.244.2.5   k8s-c2-worker   <none>           <none>
```

- Pods are still in the `k8s-c2-worker` node.
- And the `k8s-c2-worker2` node can schedule new pods.

</details>