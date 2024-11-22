# Service Accounts

- `Service Accounts` are namespace-scoped resources.
- You'll find at least one in each namespace.

## Create a Namespace

```shell
kubectl create ns web
```

## List the Service Account

```shell
kubectl get sa -n web
```

This default `Service Account` is created automatically.

## Describe the Service Account

```shell
kubectl describe sa -n web
```

## Cat the Service Account Token

```shell
kubectl describe secret default-token-mv7at -n web
```

Technically, we can use this token (as a user) to authenticate with the Kubernetes API.

## Create a Pod

```shell
kubectl run nginx --image=nginx --port=80
```

## Validate the Service Account Mounted in the Pod

```shell
kubectl get pod nginx -o yaml | grep volumeMounts -A14

    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-5q2kv
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: docker-desktop
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
```

## Get the Service Account Token Mounted Automatically in the Pod

```shell
kubectl exec nginx -it -- sh

# cat /var/run/secrets/kubernetes.io/serviceaccount/token
eyJhbGciOiJSUzI1NiIsImtpZCI6Ikh0dUZEUUdOS0otb3ZaMVNXLWNmV2ZDNGJfa3oxN1JCOXItVEtoeVplMFEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzU0MjM3OTE1LCJpYXQiOjE3MjI3MDE5MTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJuZ2lueCIsInVpZCI6ImQwMDVjZjg1LTVmMDgtNGE0Yy1hNDNlLWRjMjBkYWUzZmU1MiJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjA1NTQyZTc0LTgyNWUtNGMwMS1hYmU2LTMxZjA4NGIwM2Y5MyJ9LCJ3YXJuYWZ0ZXIiOjE3MjI3MDU1MjJ9LCJuYmYiOjE3MjI3MDE5MTUsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.XKpwenkOxeAXp2PxH5XgJHVXzSof09XaUvC8hw5EgxrG7ZcLITwjBXIFb8Eb34fxin0pFDPSXKaT15ekzKoW-Qr1K1tBmX4ET-3MQySnxgeLM1Lnzc7ECMhHKChVBrKR4qGjSmlKk4SOijKsGflmqfmZdASz0h-UrPMHjexnxIJs1PH23djnBBc-G0A2bnLn0-91xUuVYLetEX3xwQVbVK3BHITvst59--cXmc0eYpibcwuabUltvvnx0P1OElJu41ZEUaCgFoZywCA8MLK9RMpiQspYTmCSaluZR89-AjBzepW773HlbKvlV6UgDftW6OcJwQThp5xwvisMxM1YEA
```

## Create new Service Account and Prevent Auto Mount the Token

```shell
kubectl create sa nomount-sa --dry-run=client -o yaml > yaml-definitions/nomount-sa.yaml
```

### Set automountServiceAccountToken to false

```shell
echo "automountServiceAccountToken: false" >> yaml-definitions/nomount-sa.yaml
```

### Create the new Service Account

```shell
kubectl apply -f yaml-definitions/nomount-sa.yaml
```

## Create a Pod and use the nomount-sa Service Account

```shell
kubectl run nomount-sa-pod --image=nginx --port=80 --dry-run=client -o yaml > yaml-definitions/nomount-sa-pod.yaml
```

### Add the nomount-sa Service Account to the nomount-sa-pod YAML definition

```shell
spec:
  serviceAccountName: nomount-sa
```

### Create the nomount-sa-pod

```shell
kubectl apply -f yaml-definitions/nomount-sa-pod.yaml
```

### Validate the volumeMounts option

```shell
kubectl get pod nomount-sa-pod -o yaml | grep volumeMounts -A14
No result
```
