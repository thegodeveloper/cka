# Question 33 - Multi Containers Sidecar - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- The Pod named `multi-pod` is running in the cluster and it is logging to a volume.
- Insert a `sidecar` container into the Pod that will also read the logs from the volume using this command `tail -f /var/busybox/log/*.log`.
- `sidecar` specifications given below.

- **Image:** busybox:1.28
- **Name:** sidecar
- **volumePath:** /var/busybox/log

## Solution

<details>
  <summary>Show the solution</summary>

### Validate the Pod

```shell
k get pods -o wide
NAME          READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
application   1/1     Running   0          40m   10.244.1.7   k8s-c1-worker    <none>           <none>
backend       1/1     Running   0          40m   10.244.2.6   k8s-c1-worker2   <none>           <none>
frontend      1/1     Running   0          40m   10.244.2.5   k8s-c1-worker2   <none>           <none>
multi-pod     1/1     Running   0          40m   10.244.1.9   k8s-c1-worker    <none>           <none>
```

### Validate the service in the Pod

```shell
docker exec -it k8s-c1-worker bash
root@k8s-c1-worker:/# curl 10.244.1.9
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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

### Get the YAML definition of the Pod and create a backup

````shell
k get pod multi-pod -o yaml > 33.yaml
cp 33.yaml 33-bkp.yaml
````

### Remove the unnecessary configuration from the YAML definition

From the `33.yaml` remove all the unnecessary configuration until you get the following:

```shell
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
  namespace: default
spec:
  containers:
  - image: nginx:latest
    name: web-pod
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - mountPath: /var/log/nginx
      name: hostpath-volume
  volumes:
  - hostPath:
      path: /var/volume
    name: hostpath-volume
```

### Add the sidecar to the configuration

Copy the existing container and edit accordingly to the question:

```shell
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
  namespace: default
spec:
  containers:
  - image: nginx:latest
    name: web-pod
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - mountPath: /var/log/nginx
      name: hostpath-volume
  - image: busybox:1.28
    name: sidecar
    command: ['sh', '-c', 'tail -f /var/busybox/log/*.log']
    volumeMounts:
    - mountPath: /var/busybox/log
      name: hostpath-volume
  volumes:
  - hostPath:
      path: /var/volume
    name: hostpath-volume
```

### Delete the existing Pod

```shell
k delete pod multi-pod
pod "multi-pod" deleted
```

### Apply the new YAML definition

```shell
k apply -f 33.yaml
pod/multi-pod created
```

### Validate the status of the Pod

```shell
k get pod multi-pod
NAME        READY   STATUS    RESTARTS   AGE
multi-pod   2/2     Running   0          85s
```

### Describe the Pod

```shell
k describe pod multi-pod
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  38s   default-scheduler  Successfully assigned default/multi-pod to k8s-c1-worker
  Normal  Pulling    38s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     35s   kubelet            Successfully pulled image "nginx:latest" in 2.996s (2.996s including waiting)
  Normal  Created    35s   kubelet            Created container web-pod
  Normal  Started    35s   kubelet            Started container web-pod
  Normal  Pulling    35s   kubelet            Pulling image "busybox:1.28"
  Normal  Pulled     31s   kubelet            Successfully pulled image "busybox:1.28" in 4.46s (4.46s including waiting)
  Normal  Created    31s   kubelet            Created container sidecar
  Normal  Started    30s   kubelet            Started container sidecar
```

### Get logs from the sidecar container

```shell
k logs multi-pod -c sidecar -f 
k logs multi-pod -c sidecar -f                                                                                                                                                           ─╯
==> /var/busybox/log/access.log <==
10.244.1.1 - - [23/Nov/2024:17:13:21 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.74.0" "-"

==> /var/busybox/log/error.log <==
2024/11/23 17:39:47 [notice] 1#1: start worker process 34
2024/11/23 17:39:47 [notice] 1#1: start worker process 35
2024/11/23 17:39:47 [notice] 1#1: start worker process 36
2024/11/23 17:39:47 [notice] 1#1: start worker process 37
2024/11/23 17:39:47 [notice] 1#1: start worker process 38
2024/11/23 17:39:47 [notice] 1#1: start worker process 39
2024/11/23 17:39:47 [notice] 1#1: start worker process 40
2024/11/23 17:39:47 [notice] 1#1: start worker process 41
2024/11/23 17:39:47 [notice] 1#1: start worker process 42
2024/11/23 17:39:47 [notice] 1#1: start worker process 43
```

### List the Pod 

```shell
k get pod multi-pod -o wide
NAME        READY   STATUS    RESTARTS   AGE     IP             NODE            NOMINATED NODE   READINESS GATES
multi-pod   2/2     Running   0          4m17s   10.244.235.1   k8s-c1-worker   <none>           <none>
```

### Validate the service in the Pod

```shell
docker exec -it k8s-c1-worker bash -c "curl http://10.244.235.1"
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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