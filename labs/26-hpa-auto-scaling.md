# Question 26 - HPA Auto Scaling - 6%

## Use context

```shell
kubectl config use kind-k8s-c4
```

## Task Definition

- Auto-scale the existing deployment `frontend` in `production` namespace at `80%` of Pod CPU usage.
- Set Minimum replicas to `3` and Maximum replicas to `5`.

## Solution

<details>
  <summary>Show the solution</summary>

### Validate the deployment

```shell
k -n production get deploy
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
frontend   2/2     2            2           19s
```

### Auto-scale the deployment 'frontend' in 'production' namespace

```shell
k -n production autoscale deploy frontend --min=3 --max=5 --cpu-percent=80
horizontalpodautoscaler.autoscaling/frontend autoscaled
```

### Check the HPA created in 'production' namespace

```shell
k -n production get hpa
NAME       REFERENCE             TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
frontend   Deployment/frontend   <unknown>/80%   3         5         3          99s
```

### Validate the number of replicas set on HPA

```shell
k -n production get deploy frontend
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
frontend   3/3     3            3           9m31s
```

The number of replicas should be set to `3`.

</details>