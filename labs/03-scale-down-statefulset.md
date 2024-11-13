# Scale Down Statefulset - 1%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- There are two Pods named `o3db-*` in Namespace `project-c13`.
- Scale the Pods down to one replica to save resources.
- Record the action.

## Solution

<details>
  <summary>Show the solution</summary>

#### Check the Pods

```shell
k get pods -n project-c13 | grep o3db
o3db-0   1/1     Running   0          2m52s
o3db-1   1/1     Running   0          2m47s
```

#### Identify if they are managed by a statefulset

```shell
k get deploy,sts,ds -n project-c13 | grep o3db
statefulset.apps/o3db   2/2     4m13s
```

#### Identify them from Pods

```shell
k get pod --show-labels -n project-c13 | grep o3db
o3db-0   1/1     Running   0          5m32s   app=nginx,apps.kubernetes.io/pod-index=0,controller-revision-hash=o3db-6df8f484ff,statefulset.kubernetes.io/pod-name=o3db-0
o3db-1   1/1     Running   0          5m27s   app=nginx,apps.kubernetes.io/pod-index=1,controller-revision-hash=o3db-6df8f484ff,statefulset.kubernetes.io/pod-name=o3db-1
```

#### Scale down the statefulset and record the action

```shell
k scale sts o3db -n project-c13 --replicas 1 --record
Flag --record has been deprecated, --record will be removed in the future
statefulset.apps/o3db scaled
```

#### Validate the Pods in the StatefulSet

```shell
k get sts o3db -n project-c13
NAME   READY   AGE
o3db   1/1     7m53s
```

#### List the pods

```shell
k get pods -n project-c13 | grep o3db
o3db-0   1/1     Running   0          8m20s
```

</details>
