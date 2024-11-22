# Taints and Tolerations

- By default, application Pods will not run on the control plane node. 
- The control plane has a special attribute assigned to it called a `taint`.
- A `taint` will repel work, meaning it will disable scheduling to that node unless a certain specification exists in the YAML spec called `toleration`.

## Get the taints in the control-plane nodes

```shell
docker exec -it cka-control-plane
```

```shell
kubectl describe no | grep Taints                                                                                                                                            ─╯
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Taints:             <none>
Taints:             <none>
```

## Taint a node

```shell
kubectl taint no cka-worker dedicated=special-user:NoSchedule
node/cka-worker tainted
```

```shell
kubectl describe no cka-worker | grep Taints
Taints:             dedicated=special-user:NoSchedule
```

## View a Pod toleration

### Identify the CoreDNS Pods

```shell
kubectl get po -l k8s-app=kube-dns -n kube-system

NAME                       READY   STATUS    RESTARTS   AGE
coredns-76f75df574-4sq48   1/1     Running   0          37m
coredns-76f75df574-btzzt   1/1     Running   0          38m
```

```shell
kubectl get pod coredns-76f75df574-4sq48 -o yaml -n kube-system | grep tolerations -A14
  tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - configMap:
```

This effect and key `must match` exactly with the taint of the node.

```yaml
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
```

Should match with this taint in the node:

```shell
k describe no cka-control-plane | grep Taints                                                                                                                                      ─╯
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
```

## Create a Pod that has a toleration

The `taint` had an effect of `NoSchedule`, a value of `special-user`, a key named `dedicated`.

### Create a Pod template

```shell
k run pod-tolerate --image=nginx --dry-run=client -o yaml > yaml-definitions/pod-tolerate.yaml
```

### Add tolerations to the yaml-definitions/pod-tolerate.yaml file

```shell
spec:
  tolerations:
  - key: "dedicated"
    value: "special-user"
    effect: "NoSchedule"
  containers:
```

### Submit the YAML file to the API Server

```shell
kubectl create -f yaml-definitions/pod-tolerate.yaml
pod/pod-tolerate created
```

### Validate the Pod

```shell
kubectl get po -o wide

NAME           READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
pod-tolerate   1/1     Running   0          78s   10.244.1.4   cka-worker2   <none>           <none>
```