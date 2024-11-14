# Question 10 - RBAC ServiceAccount Role RoleBinding - 6%

## Use Context kind-cka

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create a new `ServiceAccount` `processor` in Namespace `project-hamster`.
- Create a `Role` and `RoleBinding`, both named `processor` as well.
- These should allow the new `ServiceAccount` to only create `Secrets` and `ConfigMaps` in the Namespace.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the project-hamster namespace

```shell
k create ns project-hamster
namespace/project-hamster created
```

### Create the ServiceAccount

```shell
k -n project-hamster create sa processor
serviceaccount/processor created
```

### Create a Role named processor

```shell
k -n project-hamster create role processor \
  --verb=create \
  --resource=secrets \
  --resource=configmap
role.rbac.authorization.k8s.io/processor created
```

### Create the RoleBinding

```shell
k -n project-hamster create rolebinding processor \
  --role processor \
  --serviceaccount project-hasmter:processor
rolebinding.rbac.authorization.k8s.io/processor created
```

### Validate the permissions


#### Get auth can-i examples

```shell
k auth can-i -h
```

#### Validate if the ServiceAccount can create secrets

```shell
k -n project-hamster auth can-i create secret \
  --as system:serviceaccount:project-hasmter:processor
yes
```

#### Validate if the ServiceAccount can create configmap

```shell
k -n project-hamster auth can-i create configmap \
  --as system:serviceaccount:project-hasmter:processor
yes
```

#### Validate if the ServiceAccount can create pod

```shell
k -n project-hamster auth can-i create pod \
  --as system:serviceaccount:project-hasmter:processor
no
```

### Validate if the ServiceAccount can delete secret

```shell
k -n project-hamster auth can-i delete secret \
  --as system:serviceaccount:project-hasmter:processor
no
```

#### Validate if the ServiceAccount can get configmap 

```shell
k -n project-hamster auth can-i get configmap \
  --as system:serviceaccount:project-hasmter:processor
no
```
</details>
