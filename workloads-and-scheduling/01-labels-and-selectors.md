# Labels and Selectors

## Create Dev and Prod Deployments

### Dev Deployment

```shell
kubectl create deploy nginx-dev --image=nginx --port=80 --replicas=3
```

### Prod Deployment

```shell
kubectl create deploy nginx-prod --image=nginx --port=80 --replicas=3
```

## Selectors

```shell
kubectl get pods -l app=nginx-dev
```

```shell
kubectl get pods -l app=nginx-prod
```

