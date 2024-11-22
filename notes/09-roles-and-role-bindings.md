# Roles and Role Bindings

Roles and Role Bindings define privileges in a namespace, where Cluster Roles and Cluster Role Bindings define cluster-wide privileges.

- Role
- Cluster Role
- Role Binding
- Cluster Role Binding

## Type of users accessing namespaced resources versus cluster resources

- Application developers will commonly be assigned `Roles` because they develop applications that exist inside a namespace.
- Cluster administrators will commonly be assigned `Cluster Roles` because they are updating nodes and creating volumes and other operations outside of the namespace (cluster-wide).

## Role Example

```shell
kubectl create role pod-reader --verb=get,list,watch --resource=pods
```

### Generate a YAML definition of the Role

```shell
kubectl create role pod-reader --verb=get,list,watch --resource=pods --dry-run=client -o yaml > yaml-definitions/role.yaml
```

## Role Bindings

- Notice that this `Role` doesn't indicate permissions for a user. 
- That's where `Role Bindings` come in. 
- `Role Bindinds` will attach (or bind) a `Role` to a `User`, `Group`, or `Service Account` with a `Role`.

### Create a Role Binding

```shell
kubectl create rolebinding pod-reader-binding --role=pod-reader --user=angelina
```

This `Role Binding` is how the user `angelina` will be authorized to access `Pods` in the Kubernetes cluster.

## Verify is a user can perform an action in Kubernetes

### Check if I can list deployments in current namespace

```shell
kubectl auth can-i list deployments.apps
```

### Check if I can do everything in the current namespace

```shell
kubectl auth can-i '*' '*'
```

### Check if I can get the job named "bar" in namespace "foo"

```shell
kubectl auth can-i list jobs.batch/bar -n foo
```

### Check if I can read pod logs

```shell
kubectl auth can-i get pods --subresource=log
```

### Check if I can access the URL /logs/

```shell
kubectl auth can-i get /logs/
```

### List all allowed actions in namespace "foo"

```shell
kubectl auth can-i --list --namespace=foo
```

## Impersonate a user to verify permissions

```shell
kubectl auth can-i get pods -n default --as angelina
```

```shell
kubectl auth can-i delete pods -n default --as angelina
```