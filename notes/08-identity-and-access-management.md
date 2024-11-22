# Identity & Access Management

## Create a Kind cluster

```shell
kind create cluster --name cka --config yaml-definitions/cluster.yaml
```

## Get the IP address of the control plane

```shell
kubectl cluster-info --context kind-cka | grep "Kubernetes"                                                                                                                  ─╯
Kubernetes control plane is running at https://127.0.0.1:49603
```

Or

```shell
kubectl config view | grep -B 3 "name: kind-cka" | head -n 4 | grep "server:"
    server: https://127.0.0.1:49603
```

## Create the pod-deploy-reader role

```shell
kubectl create role pod-deploy-reader --verb=get --verb=list --verb=watch --resource=pods,deployments
role.rbac.authorization.k8s.io/pod-deploy-reader created
```

## Create the role binding

```shell
kubectl create rolebinding pod-deploy-reader-binding --role=pod-deploy-reader --serviceaccount=default:default
```

## Create the token (deprecated)

```shell
TOKEN=$(kubectl get secret -n default -o json | jq -r '(.items[].data.token)' | base64 --decode | tr -d "\n")
```

## New Bound Tokens

To use the default token for your SA, you create a Pod in the cluster. The token for the Pod is located under the directory: `/var/run/secrets/kubernetes.io/serviceaccount`.

### Create a pod

```shell
kubectl run nginx --image=nginx --restart=Never --port=80
pod/nginx created
```

### Obtain the default Token for the SA

```shell
kubectl exec -it nginx -n default -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

eyJhbGciOiJSUzI1NiIsImtpZCI6Im5qYnQyQUpTd0luWU8tSjc0ZHFYWW96Unhfc3JSaVlkRkprTEw1aEJSQzgifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzUzMjIxODY0LCJpYXQiOjE3MjE2ODU4NjQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJuZ2lueCIsInVpZCI6IjkwYzBkZTdiLThjZjQtNGVlOS1hYjBlLThmYzVmM2Y4MWRmYSJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjU3ZmIzNmI4LTNjZmQtNDRjMi05OWE5LTRkY2EyMjYxOGQ1MyJ9LCJ3YXJuYWZ0ZXIiOjE3MjE2ODk0NzF9LCJuYmYiOjE3MjE2ODU4NjQsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.Lm5T3tfwd4N5kj77xCBoHaPm4lCeuEenknle9EUAhtttSBb3Rco4mem5gqRr4W5tykJUcOQpNdB8wvjYApWkQTZtcFcUn2hQq2cQ5Gv9gq60nOtbGcUAs7KjcG42_-EcQ0ARbke4URc1F2IwNVtPWWQw7pETF0ZLkMnGAJzUhdQBCt_ODCIIISz29-jfpsw7ACuWV5gj9NuJGHKZrVS14H3cXcc3bfeXM34xD0iLau1q2PG4-F1n3c2m_-V0xTK26ADTzTH8ky4napq5h2nHVxYBAw8PmB-C7C_Hn3UJFnCt4NsQuhzZGV7phpVTHEtu3M2D4Y6cJtH9QAuvj9u-1g
```

### Connect to control plane

```shell
docker exec -it cka-control-plane bash
```

### Generate a token

```shell
root@cka-control-plane:/# TOKEN=$(kubectl exec -it nginx -n default -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d "\n")
root@cka-control-plane:/# echo $TOKEN
eyJhbGciOiJSUzI1NiIsImtpZCI6Im5qYnQyQUpTd0luWU8tSjc0ZHFYWW96Unhfc3JSaVlkRkprTEw1aEJSQzgifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzUzMjIxODY0LCJpYXQiOjE3MjE2ODU4NjQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJuZ2lueCIsInVpZCI6IjkwYzBkZTdiLThjZjQtNGVlOS1hYjBlLThmYzVmM2Y4MWRmYSJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjU3ZmIzNmI4LTNjZmQtNDRjMi05OWE5LTRkY2EyMjYxOGQ1MyJ9LCJ3YXJuYWZ0ZXIiOjE3MjE2ODk0NzF9LCJuYmYiOjE3MjE2ODU4NjQsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.Lm5T3tfwd4N5kj77xCBoHaPm4lCeuEenknle9EUAhtttSBb3Rco4mem5gqRr4W5tykJUcOQpNdB8wvjYApWkQTZtcFcUn2hQq2cQ5Gv9gq60nOtbGcUAs7KjcG42_-EcQ0ARbke4URc1F2IwNVtPWWQw7pETF0ZLkMnGAJzUhdQBCt_ODCIIISz29-jfpsw7ACuWV5gj9NuJGHKZrVS14H3cXcc3bfeXM34xD0iLau1q2PG4-F1n3c2m_-V0xTK26ADTzTH8ky4napq5h2nHVxYBAw8PmB-C7C_Hn3UJFnCt4NsQuhzZGV7phpVTHEtu3M2D4Y6cJtH9QAuvj9u-1g
```

### Get Pods

```shell
curl -X GET https://cka-control-plane:6443/api/v1/namespaces/default/pods --header "Authorization: Bearer $TOKEN"  --cacert /etc/kubernetes/pki/ca.crt
```

### Get Deployments

```shell
curl -X GET https://cka-control-plane:6443/apis/apps/v1/namespaces/default/deployments --header "Authorization: Bearer $TOKEN"  --cacert /etc/kubernetes/pki/ca.crt
```

## Resources

- [New Service Account Tokens](https://luandy-4171.medium.com/kubernetes-new-service-account-tokens-25adf0d9c164)
