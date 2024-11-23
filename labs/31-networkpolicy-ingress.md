# Question 31 - Network Policy Ingress - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- You have a Kubernetes cluster that runs three-tier web application.
- A `frontend` tier (port 1111), an `application` tier (port 2222), and a `backend` tier (3333).
- The security team has mandated that the `backend tier` should only be accessible from `application tier`.

## Solution

<details>
  <summary>Show the solution</summary>

### Validate the Pods

```shell
k get pods -o wide
NAME          READY   STATUS    RESTARTS   AGE     IP              NODE             NOMINATED NODE   READINESS GATES
application   1/1     Running   0          7m29s   10.244.88.194   k8s-c1-worker2   <none>           <none>
backend       1/1     Running   0          7m23s   10.244.88.195   k8s-c1-worker2   <none>           <none>
frontend      1/1     Running   0          6s      10.244.88.196   k8s-c1-worker2   <none>           <none>
```

### Validate the access from frontend to backend with curl

```shell
k exec frontend -- curl -s 10.244.88.195:3333
backend tier
```

This confirms that the `frontend` can access the `backend`.

### Validate the access from application tier to backend tier with curl

```shell
k exec application -- curl -s 10.244.88.195:3333
backend tier
```

### Validate the Pods Labels

```shell
k get pods --show-labels
NAME          READY   STATUS    RESTARTS   AGE     LABELS
application   1/1     Running   0          4m10s   app=application
backend       1/1     Running   0          16m     app=backend
frontend      1/1     Running   0          9m3s    app=frontend
```

### Create the Network Policy

- Go to the Kubernetes documentation and search for `Network Policy`.
- Search the YAML Network Policy definition.
- We need to create an `ingress policy` in the `backend` tier.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-np
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: application
    ports:
    - protocol: TCP
      port: 3333
```

Create the file `31.yaml` with the above content:

### Apply the Network Policy

````shell
k apply -f 31.yaml
networkpolicy.networking.k8s.io/backend-ingress-np created
````

### Check the connection from frontend tier to backend tier

Should be denied.

```shell
k exec frontend -- curl -s 10.244.88.195:3333
^C
```

There is no connection from the `frontend` tier to the `backend` tier.

### Validate the connection from application tier to backend tier

Should be successful.

````shell
k exec application -- curl -s 10.244.88.195:3333
backend tier
````




</details>