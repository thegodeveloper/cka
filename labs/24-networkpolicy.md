# Question 24 - NetworkPolicy - 9%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.
- To prevent this create a `NetworkPolicy` called `np-backend` in Namespace `project-snake`. It should allow the `backend-*` Pods only to:
  - connect to `db1-*` Pods on port `1111`.
  - connect to `db2-*` Pods on port `2222`.
- Use the `app` label of Pods in your policy.
- After implementation, connections from `backend-*` Pods to `vault-*` Pods `3333` should for example no longer work.

## Solution

<details>
  <summary>Show the solution</summary>

### Validate existing Pods and their labels

```shell
k -n project-snake get pod
NAME        READY   STATUS    RESTARTS   AGE
backend-0   1/1     Running   0          52s
db1-0       1/1     Running   0          42s
db2-0       1/1     Running   0          31s
vault-0     1/1     Running   0          20s
```

### Validate the labels of the Pods

```shell
k -n project-snake get pod -L app
NAME        READY   STATUS    RESTARTS   AGE     APP
backend-0   1/1     Running   0          3m16s   backend
db1-0       1/1     Running   0          3m6s    db1
db2-0       1/1     Running   0          2m55s   db2
vault-0     1/1     Running   0          2m44s   vault
```

### Validate the connection

```shell
k -n project-snake get pod -o wide
NAME        READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
backend-0   1/1     Running   0          4m19s   10.244.2.8   k8s-c1-worker    <none>           <none>
db1-0       1/1     Running   0          4m9s    10.244.2.9   k8s-c1-worker    <none>           <none>
db2-0       1/1     Running   0          3m58s   10.244.1.6   k8s-c1-worker2   <none>           <none>
vault-0     1/1     Running   0          3m47s   10.244.1.7   k8s-c1-worker2   <none>           <none>
```

```shell
k -n project-snake exec backend-0 -- curl -s 10.244.2.9:1111
database one

k -n project-snake exec backend-0 -- curl -s 10.244.1.6:2222
database two

k -n project-snake exec backend-0 -- curl -s 10.244.1.7:3333
vault secret storage
```

### Create a NetworkPolicy by copying and changing an example from the Kubernetes docs

```shell
vim 24-np.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db1
    ports:
    - protocol: TCP
      port: 1111
  - to:
    - podSelector:
        matchLabels:
          app: db2
    ports:
    - protocol: TCP
      port: 2222

```

### Apply the NetworkPolicy

```shell
k apply -f 24-np.yaml
networkpolicy.networking.k8s.io/np-backend created
```

### Validate the NetworkPolicy

```shell
k -n project-snake exec backend-0 -- curl -s 10.244.2.9:1111
database one

k -n project-snake exec backend-0 -- curl -s 10.244.1.6:2222
database two

k -n project-snake exec backend-0 -- curl -s 10.244.1.7:3333
```

</details>
