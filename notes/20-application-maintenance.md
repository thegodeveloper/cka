# Application Maintenance

## Create Kind cluster

Follow the instructions to create cluster in [Create Cluster](00-create-cluster.md).

## Validate the cluster

```shell
kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   36s   v1.29.0
cka-worker          Ready    <none>          13s   v1.29.0
cka-worker2         Ready    <none>          14s   v1.29.0
```

## Create a Deployment in the cluster

```shell
kubectl create deploy nginx --image=nginx --replicas=3
deployment.apps/nginx created
```

## Validate the Deployment

```shell
kubectl get deploy nginx
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   3/3     3            3           3m47s
```

## Disable scheduling to cka-worker node

```shell
kubectl cordon cka-worker
node/cka-worker cordoned
```

## Validate the Node States

```shell
kubectl get nodes
NAME                STATUS                     ROLES           AGE   VERSION
cka-control-plane   Ready                      control-plane   11m   v1.29.0
cka-worker          Ready,SchedulingDisabled   <none>          11m   v1.29.0
cka-worker2         Ready                      <none>          11m   v1.29.0
```

## Validate the deployment Pods

```shell
kubectl get pods -l app=nginx -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
nginx-7854ff8877-cqj67   1/1     Running   0          11m   10.244.1.3   cka-worker2   <none>           <none>
nginx-7854ff8877-h4rvm   1/1     Running   0          11m   10.244.1.2   cka-worker2   <none>           <none>
nginx-7854ff8877-mlmqb   1/1     Running   0          11m   10.244.2.2   cka-worker    <none>           <none>
```

The Pods continue working in the node, but no new pods are schedule in the node.

## Create a Second Deployment

```shell
kubectl create deploy nginx2 --image=nginx --replicas=3
deployment.apps/nginx2 created
```

## Validate the Pods for the new Deployment

```shell
kubectl get pods -l app=nginx2 -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
nginx2-9498d8f59-9ls5w   1/1     Running   0          52s   10.244.1.6   cka-worker2   <none>           <none>
nginx2-9498d8f59-q7v42   1/1     Running   0          52s   10.244.1.5   cka-worker2   <none>           <none>
nginx2-9498d8f59-vbjv5   1/1     Running   0          52s   10.244.1.4   cka-worker2   <none>           <none>
```

All the pods were created in the node `cka-worker2` because the node `cka-worker` is not ready to receive new services.

## Drain the node cka-worker

```shell
kubectl drain cka-worker --ignore-daemonsets
node/cka-worker already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-fnfch, kube-system/kube-proxy-khvcr
evicting pod default/nginx-7854ff8877-mlmqb
pod/nginx-7854ff8877-mlmqb evicted
node/cka-worker drained
```

## Validate the pods for Deployment nginx

```shell
kubectl get pods -l app=nginx -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
nginx-7854ff8877-cqj67   1/1     Running   0          18m   10.244.1.3   cka-worker2   <none>           <none>
nginx-7854ff8877-h4rvm   1/1     Running   0          18m   10.244.1.2   cka-worker2   <none>           <none>
nginx-7854ff8877-s95rl   1/1     Running   0          45s   10.244.1.7   cka-worker2   <none>           <none>
```

Now, the pod that was running in the `cka-worker` node was removed and schedule in the `cka-worker2` node.

## Enable Scheduling for the cka-worker node

```shell
kubectl get nodes
NAME                STATUS                     ROLES           AGE   VERSION
cka-control-plane   Ready                      control-plane   22m   v1.29.0
cka-worker          Ready,SchedulingDisabled   <none>          22m   v1.29.0
cka-worker2         Ready                      <none>          22m   v1.29.0
```

```shell
kubectl uncordon cka-worker
node/cka-worker uncordoned
```

```shell
kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   23m   v1.29.0
cka-worker          Ready    <none>          23m   v1.29.0
cka-worker2         Ready    <none>          23m   v1.29.0
```

## Validate the pods running for nginx and nginx2

```shell
kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP           NODE          NOMINATED NODE   READINESS GATES
nginx-7854ff8877-cqj67   1/1     Running   0          22m     10.244.1.3   cka-worker2   <none>           <none>
nginx-7854ff8877-h4rvm   1/1     Running   0          22m     10.244.1.2   cka-worker2   <none>           <none>
nginx-7854ff8877-s95rl   1/1     Running   0          5m15s   10.244.1.7   cka-worker2   <none>           <none>
nginx2-9498d8f59-9ls5w   1/1     Running   0          9m40s   10.244.1.6   cka-worker2   <none>           <none>
nginx2-9498d8f59-q7v42   1/1     Running   0          9m40s   10.244.1.5   cka-worker2   <none>           <none>
nginx2-9498d8f59-vbjv5   1/1     Running   0          9m40s   10.244.1.4   cka-worker2   <none>           <none>
```

All the pods are running in the `cka-worker2` node.

## Clean the environment

### Delete the Deployments

```shell
kubectl delete deploy nginx
deployment.apps "nginx" deleted
```

```shell
kubectl delete deploy nginx2
deployment.apps "nginx2" deleted
```

### Delete the cluster

```shell
kind delete cluster cka
```