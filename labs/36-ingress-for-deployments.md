# Question 36 - Ingress for Deployments - 6%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- There are two existing `Deployments` in Namespace `world` which should be made accessible via an `Ingress`.
- Create a `ClusterIP Services` for both `Deployments` for port `80`.
- The `Services` should have the same name as the `Deployments`.
- The `Nginx Ingress Controller` is currently installed in the cluster.
- Create a new `ingress` resource called `world` for domain name `world.universe.mine`. The domain points to the Kubernetes Node IP via `/etc/hosts`.
- The `ingress` resource should have two routes pointing to the existing `Services`.
- http://world.universe.mine/europe/
- http://world.universe.mine/asia/

## Solution

<details>
  <summary>Show the solution</summary>

### Find the Deployments

```shell
k -n world get deployment
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
asia     1/1     1            1           28s
europe   1/1     1            1           28s
```

### Expose the deployments 

```shell
k -n world expose deployment asia --port=80
service/asia exposed
```

```shell
k -n world expose deployment europe --port=80
service/europe exposed
```

### Check the services

```shell
k -n world get svc
NAME     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
asia     ClusterIP   10.96.200.133   <none>        80/TCP    27s
europe   ClusterIP   10.96.91.133    <none>        80/TCP    3s
```

### Check the Ingress Controller

````shell
k get ns
NAME                 STATUS   AGE
default              Active   91m
ingress-nginx        Active   91m
kube-node-lease      Active   91m
kube-public          Active   91m
kube-system          Active   91m
local-path-storage   Active   91m
project-a            Active   91m
project-b            Active   91m
project-c            Active   91m
project-c13          Active   91m
project-hamster      Active   91m
project-snake        Active   91m
project-tiger        Active   91m
world                Active   90m
````

```shell
k -n ingress-nginx get svc
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.51.218   172.18.0.201   80:32303/TCP,443:31166/TCP   62m
ingress-nginx-controller-admission   ClusterIP      10.96.187.6    <none>         443/TCP                      62m
```

### Find and copy the IngressClass Name

```shell
k get ingressclass
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       90m
```

### Create the Ingress Configuration 

- Go to the documentation and search for `ingress`.
- Copy the `minimal-ingress.yaml` definition.
- Create the `36.yaml` file.
- Edit the file according to the question.
- Add the `host: world.universe.mine` at the same level of `http`.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  namespace: world
spec:
  ingressClassName: nginx
  rules:
  - host: world.universe.mine
    http:
      paths:
      - path: /europe
        pathType: Prefix
        backend:
          service:
            name: europe
            port:
              number: 80
      - path: /asia
        pathType: Prefix
        backend:
          service:
            name: asia
            port:
              number: 80
```

### Apply the 36.yaml file definition

```shell
k -n world apply -f 36.yaml
ingress.networking.k8s.io/world-ingress created
```

### Validate the Ingress

```shell
k -n world get ingress
NAME            CLASS   HOSTS                 ADDRESS        PORTS   AGE
world-ingress   nginx   world.universe.mine   172.18.0.201   80      19s
```

### Describe the Ingress

```shell
k -n world describe ingress
Name:             world-ingress
Labels:           <none>
Namespace:        world
Address:          172.18.0.201
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  world.universe.mine  
                       /europe   europe:80 (10.244.88.196:80)
                       /asia     asia:80 (10.244.235.8:80)
Annotations:           nginx.ingress.kubernetes.io/rewrite-target: /
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    11s (x2 over 14s)  nginx-ingress-controller  Scheduled for sync
  Normal  Sync    11s (x2 over 14s)  nginx-ingress-controller  Scheduled for sync
```

### Validate the Ingresses

```shell
docker exec -it k8s-c1-worker bash -c "curl http://world.universe.mine/asia"
<html>
<head><title>Asia Nginx</title></head>
<body>
<h1>Hello, you reached ASIA Nginx Server!</h1>
</body>
</html>
```

```shell
docker exec -it k8s-c1-worker bash -c "curl http://world.universe.mine/europe"
<html>
<head><title>Europe Nginx</title></head>
<body>
<h1>Hello, you reached EUROPE Nginx Server!</h1>
</body>
</html>
```

</details>