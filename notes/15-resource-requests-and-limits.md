# Resource Requests & Limits

- You can apply resource requests and limits for a Pod by adding it into the container spec via YAML.
- In line with the `name` and `image` of the container.

## Create a YAML definition

```shell
kubectl run nginx --image=nginx --dry-run=client -o yaml > yaml-definitions/nginx-requests-and-limits.yaml
```

## Configure Requests and Limits

Open the `yaml-definitions/nginx-requests-and-limits.yaml` file and add the following configuration in `resources`:

```shell
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: 2
    memory: "1Gi"
```

## Apply Nginx with Resources

```shell
kubectl apply -f yaml-definitions/nginx-requests-and-limits.yaml
```

## Validate the Nginx Pod

```shell
kubectl get pod

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          5s
```
