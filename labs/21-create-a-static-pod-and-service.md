# Create a Static Pod and Service - 2%

## Use context

```shell
kubectl config use kind-k8s-c4
```

## Task Definition

- Create a `Static` Pod named `my-static-pod` in Namepsace default on `k8s-c4-control-plane`.
- It should be of image `nginx:1.16-alpine` and have resource requests for `10m` CPU and `20Mi` memory.
- Then create a `NodePort` Service named `static-pod-service` which exposes that static Pod on port `80` and check if it has `Endpoints` and if its reachable through the `k8s-c4-control-plane` internal IP address.

## Solution

<details>
  <summary>Show the solution</summary>

## Connect to k8s-c4-control-plane node

```shell
docker exec -it k8s-c4-control-plane bash
root@k8s-c4-control-plane:/#
```

## Create the Pod YAML Definition

```shell
root@k8s-c4-control-plane:/etc/kubernetes/manifests#
root@k8s-c4-control-plane:/etc/kubernetes/manifests# kubectl run my-static-pod --image=nginx:1.16-alpine -o yaml --dry-run=client > my-static-pod.yaml
```

## Edit the Pod YAML Definition

```shell
vim my-static-pod.yaml
```

```yaml
resources:
  requests:
    cpu: 10m
    memory: 20Mi
```

## Validate if the Pod is running

```shell
root@k8s-c4-control-plane:/etc/kubernetes/manifests# kubectl get pod
NAME                                 READY   STATUS    RESTARTS   AGE
my-static-pod-k8s-c4-control-plane   1/1     Running   0          2s
```

## Expose the Pod

```shell
root@k8s-c4-control-plane:/etc/kubernetes/manifests# kubectl expose my-static-pod-k8s-c4-control-plane --name static-pod-service --type=NodePort --port 80
service/static-pod-service exposed
```

## List the service

```shell
root@k8s-c4-control-plane:/etc/kubernetes/manifests# kubectl get svc,ep -l run=my-static-pod
NAME                         TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
service/static-pod-service   NodePort   10.96.9.58   <none>        80:30480/TCP   85s

NAME                           ENDPOINTS       AGE
endpoints/static-pod-service   10.244.0.6:80   85s
```

## Test the service from other node

```shell
docker exec -it k8s-c4-worker bash

root@k8s-c4-worker:/# curl 10.96.9.58
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

</details>
