# Question 36 - Ingress for Deployments - 6%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- There are two existing `Deployments` in Namespace `world` which should be made accessible via an `Ingress`.
- Create a `ClusterIP Services` for both `Deployments` for port `80`.
- The `Services` should have the same name as the `Deployments`.

## Solution

<details>
  <summary>Show the solution</summary>

### Find the Deployments

```shell
k -n world get deployment

```

</details>