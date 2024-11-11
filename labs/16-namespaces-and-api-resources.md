# Namespaces & API Resources - 2%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create Namespace called `cka-master`.
- Write the names of all namespaced Kubernetes resources (like Pod, Secret, ConfigMap...) into `namespaced_resources.txt`.
- Find the `project-*` Namespace with the highest number of `Roles` defined in it and write its name and amount of `Roles` into `crowded-namespace.txt`.

## Solution

<details>
  <summary>Show the solution</summary>

### Create Namespace

```shell
k create ns cka-master
namespace/cka-master created
```

### Write all namespaces Kubernetes resources

```shell
k api-resources
```

```shell
k api-resources -h
  # Print the supported non-namespaced resources
  kubectl api-resources --namespaced=false
```

```shell
k api-resources --namespaced=true -o name > namespaced_resources.txt
```

### Namespace with most Roles

```shell
k -n namespace_name get role --no-headers | wc -l
```

```shell
vi crowded-namespace.txt
project-x with (n) resources
```
</details>
