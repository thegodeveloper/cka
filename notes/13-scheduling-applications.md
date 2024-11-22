# Scheduling Applications

## Create a Pod YAML Definition

```shell
kubectl run ssd-pod --image=nginx --port=80 --dry-run=client -o yaml > yaml-definitions/ssd-pod.yaml
```

## Get Nodes Labels

```shell
kubectl get nodes --show-labels

NAME                STATUS   ROLES           AGE     VERSION   LABELS
cka-control-plane   Ready    control-plane   3m50s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
cka-worker          Ready    <none>          3m27s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-worker,kubernetes.io/os=linux
cka-worker2         Ready    <none>          3m28s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-worker2,kubernetes.io/os=linux
```
## Apply a Label to a Node

The `cka-worker` node is the first of the worker nodes. There are three nodes:

- cka-control-plan
- cka-worker
- cka-worker2

```shell
kubectl label no cka-worker disktype=ssd
node/cka-worker labeled
```

### Check the labels in the node

```shell
kubectl get no cka-worker --show-labels

NAME         STATUS   ROLES    AGE     VERSION   LABELS
cka-worker   Ready    <none>   7m12s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-worker,kubernetes.io/os=linux
```

### Add a nodeSelector to the Pod YAML Definition (ssd-pod.yaml)

Add the line `nodeSelector:` in line with word `containers:`

```shell
nodeSelector:
  disktype: ssd
```

### Create the Pod

```shell
kubectl apply -f yaml-definitions/ssd-pod.yaml
pod/ssd-pod created
```

### Verify Pod Location

```shell
kubectl get pod ssd-pod -o wide

NAME      READY   STATUS    RESTARTS   AGE    IP           NODE         NOMINATED NODE   READINESS GATES
ssd-pod   1/1     Running   0          112s   10.244.2.2   cka-worker   <none>           <none>
```

## DaemonSet

List the pods and their distribution in the cluster:

```shell
kubectl get pod -n kube-system -l app=kindnet -o wide

NAME            READY   STATUS    RESTARTS   AGE     IP           NODE                NOMINATED NODE   READINESS GATES
kindnet-bm4zz   1/1     Running   0          7m58s   172.18.0.4   cka-worker          <none>           <none>
kindnet-qq8xr   1/1     Running   0          7m58s   172.18.0.2   cka-worker2         <none>           <none>
kindnet-z66rp   1/1     Running   0          8m5s    172.18.0.3   cka-control-plane   <none>           <none>
```

### Get the nodeName of one

```shell
kubectl get po kindnet-bm4zz -n kube-system -o yaml | grep nodeName -a3

  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  hostNetwork: true
  nodeName: cka-worker
  nodeSelector:
    kubernetes.io/os: linux
  preemptionPolicy: PreemptLowerPriority
```

## Create a pod in specific node

```shell
kubectl run nginx-cka-worker --image=nginx --port=80 --dry-run=client -o yaml > yaml-definitions/nginx-cka-worker.yaml
```

### Add the nodeName entry at the same label of containers

```shell
nodeName: cka-worker
```

### Apply the YAML

```shell
kubectl apply -f yaml-definitions/nginx-cka-worker.yaml
```

### Validate the pod location

```shell
kubectl get pod nginx-cka-worker -o wide

NAME               READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
nginx-cka-worker   1/1     Running   0          47s   10.244.1.2   cka-worker   <none>           <none>
```

## Node and Pod Affinity

This configuration can be flexible, an `affinity` prefers the `Pod` be scheduled to a node with the label `SSD` but will schedule to node `LINUX` if `none` exists.

### Create a brand-new Pod

```shell
kubectl run affinity --image=nginx --port=80 --dry-run=client -o yaml > yaml-definitions/affinity.yaml
```

### Append the following configuration below spec

```shell
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                  - linux
      preferredDuringSchedulingIgnoredDuringExecution:
        - preference:
            matchExpressions:
              - key: disktyp
                operator: In
                values:
                  - ssd
          weight: 1
```

Let's schedule our Pod with the following command:

```shell
kubectl apply -f yaml-definitions/affinity.yaml
pod/affinity created
```

### Validate the location of the pod

```shell
kubectl get po -o wide

NAME       READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
affinity   1/1     Running   0          52s   10.244.1.3   cka-worker   <none>           <none>
```

### Check the node labels

```shell
kubectl get no cka-worker --show-labels

NAME         STATUS   ROLES    AGE   VERSION   LABELS
cka-worker   Ready    <none>   71m   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-worker,kubernetes.io/os=linux
```

### Pod Affinity

The `Pod` will only be schedule to a node that already has an `nginx` Pod running.

#### Create a Pod that has the label run=nginx

```shell
kubectl run nginx --image=nginx --port=80
pod/nginx created
```

#### Apply the pod-node-affinity.yaml file

```shell
kubectl apply -f yaml-definitions/pod-node-affinity.yaml
pod/pod-affinity created
```

#### Validate if the pods are in the same node

```shell
kubectl get pod -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
nginx          1/1     Running   0          26m   10.244.1.4   cka-worker   <none>           <none>
pod-affinity   1/1     Running   0          75s   10.244.1.5   cka-worker   <none>           <none>
```
