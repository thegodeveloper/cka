# Expose Deployment through NodePort - 4%

## Use context

```shell
kubectl config use kind-k8s-c4
```

## Task Definition

- Expose existing deployment in `prodution` namespace named as `frontend` through `NodePort`.
- `NodePort` service name should be `frontendsvc`.

## Solution

<details>
  <summary>Show the solution</summary>

### Check the Deployment in 'production' namespace

```shell
k -n production get deploy frontend
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
frontend   3/3     3            3           21m
```

### Expose the Deployment as NodePort

```shell
k -n production expose deploy frontend --name=frontendsvc --port=80 --type=NodePort
service/frontendsvc exposed
```

### Check the service

````shell
k -n production get svc
NAME          TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
frontendsvc   NodePort   10.96.33.204   <none>        80:31433/TCP   27s
````

### Check if service is exposed or not

```shell
k get nodes -o wide
NAME                   STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
k8s-c4-control-plane   Ready    control-plane   27m   v1.29.0   172.18.0.12   <none>        Debian GNU/Linux 11 (bullseye)   6.10.11-linuxkit   containerd://1.7.1
k8s-c4-worker          Ready    <none>          27m   v1.29.0   172.18.0.13   <none>        Debian GNU/Linux 11 (bullseye)   6.10.11-linuxkit   containerd://1.7.1
```

```shell
docker exec -it k8s-c4-worker bash
root@k8s-c4-worker:/# curl http://172.18.0.13:31433
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

</details>