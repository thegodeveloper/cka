# Question 4 - Pod Ready if Service is Reachable - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create single Pod named `ready-if-service-ready` of image `nginx:1.16.1-alpine`.
- Configure a `LivenessProbe` which simple runs `true`.
- Also configure a `ReadinessProbe` which does check if the url `http://service-am-i-ready:80` is reachable.
- You can use `wget -T2 -O- http://service-am-i-ready:80`.
- Create a second Pod named `am-i-ready` of image `nginx:1.16.1-alpine` with label `id: cross-server-ready`.
- The already existing Service `service-am-i-ready` should now have that second Pod as endpoint.
- Now the first Pod should be in ready state.

It's a bit of an anti-pattern for one Pod to check another Pod for being ready using probes, hence the normally available `readinessProbe.httpGet` doesn't work for absolute remote urls. Still the workaround requested in this task should show how probes and Pod<->Service communication works.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the first Pod

```shell
k run ready-if-service-ready --image=nginx:1.16.1-alpine --dry-run=client -o yaml > 4_pod1.yaml
```

### Add the livenessProbe and readinessProbe

```yaml
image:
livenessProbe:
  exec:
    command:
      - 'true'
readinessProbe:
  exec:
    command:
      - sh
      - '-c'
      - 'wget -T2 -O- http://service-am-i-ready:80'
```

### Create the Pod

```shell
k apply -f 4_pod1.yaml
pod/ready-if-service-ready created
```

### Validate the Pod

The Ready column should be 0/1.

```shell
k get pods
NAME                     READY   STATUS    RESTARTS   AGE
ready-if-service-ready   0/1     Running   0          2m8s
```

### Create the second Pod

```shell
k run am-i-ready --image=nginx:1.16.1-alpine --labels="id=cross-server-ready"
pod/am-i-ready created
```

### Validate the Existing Service Endpoint

```shell
k describe svc service-am-i-ready
Name:              service-am-i-ready
Namespace:         default
Labels:            id=cross-server-ready
Annotations:       <none>
Selector:          id=cross-server-ready
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.35.16
IPs:               10.96.35.16
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.0.6:80
Session Affinity:  None
Events:            <none>
```

```shell
k get ep
NAME                 ENDPOINTS         AGE
kubernetes           172.18.0.2:6443   27m
service-am-i-ready   10.244.0.6:80     2m4s
```

### Validate the Pods

The `ready-if-service-ready` Pod now should have a `READY 1/1`.

```shell
k get pods
NAME                     READY   STATUS    RESTARTS   AGE
am-i-ready               1/1     Running   0          13m
ready-if-service-ready   1/1     Running   0          20m
```
</details>
