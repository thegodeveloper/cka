# Question 2 - Schedule a Pod on Master Node - 3%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create a single Pod of image ```httpd:alpine3.20``` in ```default``` namespace.
- The Pod should be named ```pod1``` and the container should be named ```pod1-container```.
- This Pod should `only` be scheduled on a master node, do not add new labels to any nodes.
- Shortly write the reason on why the Pods are by default not scheduled on master nodes into ```master_schedule_reason.txt``` file.

## Solution

<details>
  <summary>Show the solution</summary>

### Find the master nodes and their taints

#### List the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c1-control-plane   Ready    control-plane   39s   v1.29.0
k8s-c1-worker          Ready    <none>          15s   v1.29.0
k8s-c1-worker2         Ready    <none>          15s   v1.29.0
```

#### Get the master node taints and labels 

```shell
k describe node k8s-c1-control-plane | grep Taint
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
```

```shell
k describe node k8s-c1-control-plane | grep Labels -A 10
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=k8s-c1-control-plane
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Tue, 24 Sep 2024 21:53:38 -0500
```

```shell
k get node k8s-c1-control-plane --show-labels
NAME                   STATUS   ROLES           AGE     VERSION   LABELS
k8s-c1-control-plane   Ready    control-plane   4m17s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=k8s-c1-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
```

#### Create the Pod Template

```shell
k run pod1 --image httpd:2.4.41-alpine --dry-run=client -o yaml > yaml-definitions/schedule-pod-on-master-node.yaml
```

- Set the name of the container to `pod1-container`.
- Add a `tolerations`, `- effect: NoSchedule` and with key `key: node-role.kubernetes.io/control-plane`.
- `tolerations:` must be at the same level of `containers:`.
- Add `nodeSelector:` and a key `node-role.kubernetes.io/control-plane: ""`.

```yaml
containers:
tolerations:
- effect: NoSchedule
  key: node-role.kubernetes.io/control-plane
nodeSelector:
  node-role.kubernetes.io/control-plane: ""
```

It's very important to set the `tolerations:` and the `nodeSelector:` to make sure it only runs on master nodes.

#### Apply the Pod Template

```shell
k apply -f yaml-definitions/schedule-pod-on-master-node.yaml
pod/pod1 created
```

#### Validate the Pod Location

```shell
k get pod pod1 -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
pod1   1/1     Running   0          9s    10.244.0.6   k8s-c1-control-plane   <none>           <none>
```

#### Short Reason why Pods are not schedule on master nodes by default

```shell
echo 'master nodes usually have a taint defined' > master_schedule_reason.txt
```
</details>
