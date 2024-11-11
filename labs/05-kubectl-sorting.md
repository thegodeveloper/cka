# Kubectl Sorting - 1%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- There are various Pods in all namespaces.
- Write a command into `find_pods.sh` which lists all Pods sorted by their age (`metadata.creationTimestamp`).
- Write a second command into `find_pods_uid.sh` which lists all Pods sorted by field `metadata.uid`.
- Use `kubectl` sorting for both commands.

## Find cheat sheet in Kubernetes Docs

- Go to https://kubernetes.io/docs and search for `cheat sheet`.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the first command

```shell
echo 'kubectl get pods -A --sort-by=.metadata.creationTimestamp' > find_pods.sh
chmod u+x find_pods.sh
```

#### Validate the find_pods.sh command

```shell
./find_pods.sh
NAMESPACE            NAME                                        READY   STATUS    RESTARTS   AGE
kube-system          etcd-cka-control-plane                      1/1     Running   0          38m
kube-system          kube-scheduler-cka-control-plane            1/1     Running   0          38m
kube-system          kube-apiserver-cka-control-plane            1/1     Running   0          38m
kube-system          kube-controller-manager-cka-control-plane   1/1     Running   0          38m
kube-system          kindnet-x7xwx                               1/1     Running   0          38m
kube-system          kube-proxy-5v2b7                            1/1     Running   0          38m
kube-system          coredns-76f75df574-crf8j                    1/1     Running   0          38m
kube-system          coredns-76f75df574-pfc4l                    1/1     Running   0          38m
local-path-storage   local-path-provisioner-6f8956fb48-6ht9m     1/1     Running   0          38m
default              ready-if-service-ready                      1/1     Running   0          31m
default              am-i-ready                                  1/1     Running   0          23m
```

### Create the second command

```shell
echo 'kubectl get pods -A --sort-by=.metadata.uid' > find_pods_uid.sh
chmod u+x find_pods_uid.sh
```

#### Validate the find_pods_uid.sh command

```shell
./find_pods_uid.sh
NAMESPACE            NAME                                        READY   STATUS    RESTARTS   AGE
kube-system          kube-controller-manager-cka-control-plane   1/1     Running   0          44m
kube-system          kindnet-x7xwx                               1/1     Running   0          43m
kube-system          kube-proxy-5v2b7                            1/1     Running   0          43m
kube-system          kube-scheduler-cka-control-plane            1/1     Running   0          44m
default              am-i-ready                                  1/1     Running   0          28m
kube-system          etcd-cka-control-plane                      1/1     Running   0          44m
kube-system          coredns-76f75df574-crf8j                    1/1     Running   0          43m
default              ready-if-service-ready                      1/1     Running   0          36m
kube-system          coredns-76f75df574-pfc4l                    1/1     Running   0          43m
local-path-storage   local-path-provisioner-6f8956fb48-6ht9m     1/1     Running   0          43m
kube-system          kube-apiserver-cka-control-plane            1/1     Running   0          44m
```
</details>
