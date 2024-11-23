# Question 32 - Network Policy Namespaces - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- You have a Kubernetes cluster and running pods in multiple namespaces.
- The security team has mandated that the `backend` tier on `project-a` namespace should be only accessible from the `service01` Pod that are running in `project-b` namespace.
- There is a Pod named `web` in `project-b` namespace to test, should not be able to connect to `backend` tier in `project-a` namespace.
- There is also a Pod named `application` in `project-c` namespace to test, should not be able to connect to `backend` tier in `project-a` namespace.

## Solution

<details>
  <summary>Show the solution</summary>

### Validate the pods in the namespaces

#### Pods in project-a namespace

```shell
k -n project-a get pod --show-labels -o wide
NAME      READY   STATUS    RESTARTS   AGE    IP              NODE             NOMINATED NODE   READINESS GATES   LABELS
backend   1/1     Running   0          109s   10.244.88.197   k8s-c1-worker2   <none>           <none>            app=backend
```

#### Pods in project-b namespace

```shell
k -n project-b get pod --show-labels -o wide
NAME        READY   STATUS    RESTARTS   AGE    IP              NODE             NOMINATED NODE   READINESS GATES   LABELS
service01   1/1     Running   0          93s    10.244.235.4    k8s-c1-worker    <none>           <none>            app=service01
web         1/1     Running   0          100s   10.244.88.198   k8s-c1-worker2   <none>           <none>            app=web
```

#### Pods in project-c namespace

```shell
k -n project-c get pod --show-labels -o wide
NAME          READY   STATUS    RESTARTS   AGE   IP             NODE            NOMINATED NODE   READINESS GATES   LABELS
application   1/1     Running   0          83s   10.244.235.5   k8s-c1-worker   <none>           <none>            app=application
```

### Validate communication from Pods to backend service

#### Communication from service01 to backend

```shell
k -n project-b exec service01 -- curl -s 10.244.88.197:3333
backend tier
```

#### Communication from web to backend

```shell
k -n project-b exec web -- curl -s 10.244.88.197:3333
backend tier
```

#### Communication from application to backend

```shell
k -n project-c exec application -- curl -s 10.244.88.197:3333
backend tier
```

All the Pods from the namespaces [`project-b`, `project-c`] can communicate with the `backend` in `project-a` namespace.

### Label the namespaces project-a and project-b

```shell
k label namespace project-a namespace=project-a
namespace/project-a labeled
```

```shell
k label namespace project-b namespace=project-b
namespace/project-b labeled
```

### Create a Network Policy

- Go to the Kubernetes Documentation and search for `network policy` and copy the YAML file definition template.
- Create the `32.yaml` file, copy the documentation `Network Policy` definition and edit it accordingly to the question.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-np
  namespace: project-a
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          namespace: project-b
      podSelector:
        matchLabels:
          app: service01
    ports:
    - protocol: TCP
      port: 3333
```

The two conditions in the `from` section of the `ingress` in the `Network Policy` act as `OR`, we need the configuration to be an `AND` condition. To convert the `Network Policy` to an `AND` remove the `-` from the `podSelector` condition.

### Apply the 32.yaml file

```shell
k apply -f 32.yaml
networkpolicy.networking.k8s.io/backend-ingress-np created
```

### Validate communication from Pods to backend service

#### Communication from service01 to backend

```shell
k -n project-b exec service01 -- curl -s 10.244.88.197:3333
backend tier
```

#### Communication from web to backend

```shell
k -n project-b exec web -- curl -s 10.244.88.197:3333
^C
```

No connection.

#### Communication from application to backend

```shell
k -n project-c exec application -- curl -s 10.244.88.197:3333
^C
```

No connection.

</details>