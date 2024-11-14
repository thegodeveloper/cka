# Question 11 -DaemonSet on All Nodes - 4%

## Use Context kind-cka

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Use the Namespace named `project-tiger`.
- Create a `DaemonSet` named `ds-important` with image `httpd:2.4-alpine` and labels `id=ds-important` and `uuid=18426a0b-5f59-4e10-923f-c0e078e82462`.
- The Pods it creates should request 10 millicore cpu and 10 mebibyte memory.
- The Pods of that `DaemonSet` should run on all nodes, master and worker nodes.

## Solution

<details>
  <summary>Show the solution</summary>

### Create a DaemonSet

```shell
k -n project-tiger create deployment ds-important --image=httpd:2.4-alpine -o yaml --dry-run=client > 11.yaml
```

Change the following in the YAML file:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  name: ds-important
  namespace: project-tiger
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      containers:
        - image: httpd:2.4-alpine
          name: httpd
          resources:
            requests:
              cpu: 10m
              memory: 10Mi
      tolerations:
        - effect: NoSchedule
          key: node-role.kubernetes.io/control-plane
```

### Apply the YAML file

```shell
k apply -f 11.yaml
daemonset.apps/ds-important created
```

### Get the DaemonSet

```shell
k -n project-tiger get ds
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ds-important   3         3         3       3            3           <none>          2m43s
```

### List the DaemonSet Pods

Validate that is also running in `k8s-c1-control-plane` node.

```shell
k -n project-tiger get pod -o wide
NAME                 READY   STATUS    RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
ds-important-6rf7v   1/1     Running   0          3m18s   10.244.0.5   k8s-c1-control-plane   <none>           <none>
ds-important-sb7xr   1/1     Running   0          3m18s   10.244.2.2   k8s-c1-worker          <none>           <none>
ds-important-sjr47   1/1     Running   0          3m18s   10.244.1.2   k8s-c1-worker2         <none>           <none>
```
</details>
