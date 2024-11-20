# Question 9 - Kill Scheduler, Manual Scheduling - 5%

## Use Context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- SSH into the master node with `docker exec -it k8s-c2-control-plane bash`.
- `Temporarily` stop the `kube-scheduler`, in a way that you can start it again afterward.
- Create a single `Pod` named `manual-schedule` of image `httpd:2.4-alpine`, confirm its created but not scheduled on any node.
- Manually schedule that `Pod` on node `k8s-c2-control-plane`, make sure it's running.
- Start the `kube-scheduler` again and confirm its running correctly by creating a second `Pod` named `manual-schedule2` of image `httpd:2.4-alpine` and check if it's running on `k8s-c2-control-plane` cluster.

## Solution

<details>
  <summary>Show the solution</summary>

### Find the master node

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c2-control-plane   Ready    control-plane   20h   v1.29.0
k8s-c2-worker          Ready    <none>          20h   v1.29.0
k8s-c2-worker2         Ready    <none>          20h   v1.29.0
```

### Connect to k8s-c2-control-plane and check if the scheduler is running

```shell
docker exec -it k8s-c2-control-plane bash
kubectl -n kube-system get pod | grep schedule
kube-scheduler-k8s-c2-control-plane            1/1     Running   0          20h
root@k8s-c2-control-plane:/#
```

### Kill the scheduler temporarily

```shell
root@k8s-c2-control-plane:/# cd /etc/kubernetes/manifests/
root@k8s-c2-control-plane:/etc/kubernetes/manifests# mv kube-scheduler.yaml ../
root@k8s-c2-control-plane:/etc/kubernetes/manifests#
```

### Check the scheduler again

The scheduler should be stopped.

```shell
root@k8s-c2-control-plane:/etc/kubernetes/manifests# kubectl -n kube-system get pod | grep schedule
root@k8s-c2-control-plane:/etc/kubernetes/manifests#
```

### Create the manual-schedule Pod

```shell
root@k8s-c2-control-plane:/etc/kubernetes/manifests# kubectl run manual-schedule --image=httpd:2.4-alpine
pod/manual-schedule created
root@k8s-c2-control-plane:/etc/kubernetes/manifests#
```

### Confirm that has no node assigned

```shell
root@k8s-c2-control-plane:/etc/kubernetes/manifests# kubectl get pod -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
manual-schedule   0/1     Pending   0          54s   <none>   <none>   <none>           <none>
root@k8s-c2-control-plane:/etc/kubernetes/manifests#
```

### Manually schedule the Pod

```shell
kubectl get pod manual-schedule -o yaml > 9.yaml
```

### Edit the file

```yaml
spec:
  nodeName: k8s-c2-control-plane
```

### Replace the pod

```shell
kubectl -f 9.yaml replace --force
pod "manual-schedule" deleted
pod/manual-schedule replaced
```

### Validate the pod

```shell
root@k8s-c2-control-plane:~# kubectl get po manual-schedule -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
manual-schedule   1/1     Running   0          40s   10.244.0.5   k8s-c2-control-plane   <none>           <none>
```

### Start the scheduler again

```shell
cd /etc/kubernetes
root@k8s-c2-control-plane:/etc/kubernetes# ls
admin.conf  controller-manager.conf  kube-scheduler.yaml  kubelet.conf  manifests  pki  scheduler.conf  super-admin.conf
root@k8s-c2-control-plane:/etc/kubernetes# mv kube-scheduler.yaml manifests/
```

### Check the scheduler

```shell
root@k8s-c2-control-plane:/etc/kubernetes# kubectl -n kube-system get pod | grep kube-scheduler
kube-scheduler-k8s-c2-control-plane            1/1     Running   0          58s
```

### Schedule a second pod

```shell
root@k8s-c2-control-plane:/etc/kubernetes# kubectl run manual-schedule2 --image=httpd:2.4-alpine
pod/manual-schedule2 created
```

### Check the pods and their location

```shell
root@k8s-c2-control-plane:/etc/kubernetes# kubectl get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE    IP           NODE                   NOMINATED NODE   READINESS GATES
manual-schedule    1/1     Running   0          5m1s   10.244.0.5   k8s-c2-control-plane   <none>           <none>
manual-schedule2   1/1     Running   0          43s    10.244.2.4   k8s-c2-worker          <none>           <none>
```
</details>
