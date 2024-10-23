# Kill Scheduler, Manual Scheduling - 5%

## Use Context

```shell
k config use-context kind-cka
Switched to context "kind-cka".
```

## Task Definition

- SSH into the master node with `docker exec -it cka-control-plane bash`.
- `Temporarily` stop the `kube-scheduler`, in a way that you can start it again afterward.
- Create a single `Pod` named `manual-schedule` of image `httpd:2.4-alpine`, confirm its created but not scheduled on any node.
- Manually schedule that `Pod` on node `cka-control-plane`, make sure it's running.
- Start the `kube-scheduler` again and confirm its running correctly by creating a second `Pod` named `manual-schedule2` of image `httpd:2.4-alpine` and check if it's running on `cka-control-plane` cluster.

## Find the master node

```shell
k get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   20h   v1.29.0
cka-worker          Ready    <none>          20h   v1.29.0
cka-worker2         Ready    <none>          20h   v1.29.0
```

## Connect to cka-control-plane and check if the scheduler is running

```shell
docker exec -it cka-control-plane bash
kubectl -n kube-system get pod | grep schedule
kube-scheduler-cka-control-plane            1/1     Running   0          20h
root@cka-control-plane:/#
```

## Kill the scheduler temporarily

```shell
root@cka-control-plane:/# cd /etc/kubernetes/manifests/
root@cka-control-plane:/etc/kubernetes/manifests# mv kube-scheduler.yaml ../
root@cka-control-plane:/etc/kubernetes/manifests#
```

## Check the scheduler again

The scheduler should be stopped.

```shell
root@cka-control-plane:/etc/kubernetes/manifests# kubectl -n kube-system get pod | grep schedule
root@cka-control-plane:/etc/kubernetes/manifests#
```

## Create the manual-schedule Pod

```shell
root@cka-control-plane:/etc/kubernetes/manifests# kubectl run manual-schedule --image=httpd:2.4-alpine
pod/manual-schedule created
root@cka-control-plane:/etc/kubernetes/manifests#
```

## Confirm that has no node assigned

```shell
root@cka-control-plane:/etc/kubernetes/manifests# kubectl get pod -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
manual-schedule   0/1     Pending   0          54s   <none>   <none>   <none>           <none>
root@cka-control-plane:/etc/kubernetes/manifests#
```

## Manually schedule the Pod

```shell
kubectl get pod manual-schedule -o yaml > 9.yaml
```

## Install VIM

```shell
apt-get update
apt-get instal vim -y
```

## Edit the file

```yaml
spec:
  nodeName: cka-control-plane
```

## Replace the pod

```shell
kubectl -f 9.yaml replace --force
pod "manual-schedule" deleted
pod/manual-schedule replaced
```

## Validate the pod

```shell
root@cka-control-plane:~# kubectl get po manual-schedule -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
manual-schedule   1/1     Running   0          40s   10.244.0.5   cka-control-plane   <none>           <none>
```

## Start the scheduler again

```shell
cd /etc/kubernetes
root@cka-control-plane:/etc/kubernetes# ls
admin.conf  controller-manager.conf  kube-scheduler.yaml  kubelet.conf  manifests  pki  scheduler.conf  super-admin.conf
root@cka-control-plane:/etc/kubernetes# mv kube-scheduler.yaml manifests/
```

## Check the scheduler

```shell
root@cka-control-plane:/etc/kubernetes# kubectl -n kube-system get pod | grep kube-scheduler
kube-scheduler-cka-control-plane            1/1     Running   0          58s
```

## Schedule a second pod

```shell
root@cka-control-plane:/etc/kubernetes# kubectl run manual-schedule2 --image=httpd:2.4-alpine
pod/manual-schedule2 created
```

## Check the pods and their location

```shell
root@cka-control-plane:/etc/kubernetes# kubectl get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE    IP           NODE                NOMINATED NODE   READINESS GATES
manual-schedule    1/1     Running   0          5m1s   10.244.0.5   cka-control-plane   <none>           <none>
manual-schedule2   1/1     Running   0          43s    10.244.2.4   cka-worker          <none>           <none>
```