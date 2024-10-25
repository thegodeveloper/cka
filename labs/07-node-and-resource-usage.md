# Node and Pod Resource Usage - 1%

## Use Context

```shell
k config use-context kind-cka
Switched to context "kind-cka".
```

## Task Definition

- The metrics server should be installed in the cluster.
- Create a `7-node.sh` to show `node` resource usage.
- Create a `7-pod.sh` to show `pod` and their container resource usage.

## Install Metrics Server

```shell
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
"metrics-server" has been added to your repositories

helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "metrics-server" chart repository
...Successfully got an update from the "nfs-ganesha-server-and-external-provisioner" chart repository
...Successfully got an update from the "aws-ebs-csi-driver" chart repository
...Successfully got an update from the "metallb" chart repository
...Successfully got an update from the "secrets-store-csi-driver" chart repository
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "hashicorp" chart repository
...Successfully got an update from the "grafana" chart repository
...Successfully got an update from the "argo" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "gloo" chart repository
...Successfully got an update from the "datadog" chart repository
...Successfully got an update from the "bitnami-repo" chart repository
Update Complete. ⎈Happy Helming!⎈

helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system
Release "metrics-server" does not exist. Installing it now.
NAME: metrics-server
LAST DEPLOYED: Wed Oct 23 15:30:14 2024
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
* Metrics Server                                                      *
***********************************************************************
  Chart version: 3.12.2
  App version:   0.7.2
  Image tag:     registry.k8s.io/metrics-server/metrics-server:v0.7.2
***********************************************************************
```

## Validate the Metrics Server Pod

```shell
k -n kube-system get pod -l app.kubernetes.io/name=metrics-server
NAME                              READY   STATUS    RESTARTS   AGE
metrics-server-684dd857fc-qb5d2   1/1     Running   0          2m8s
```

## Solution

### List the top options

```shell
k top -h
Display resource (CPU/memory) usage.

 The top command allows you to see the resource consumption for nodes or pods.

 This command requires Metrics Server to be correctly configured and working on the server.

Available Commands:
  node          Display resource (CPU/memory) usage of nodes
  pod           Display resource (CPU/memory) usage of pods

Usage:
  kubectl top [flags] [options]

Use "kubectl top <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

### Create the 7-node.sh script

```shell
echo 'kubectl top node' > 7-node.sh
chmod u+x 7-node.sh
./7-node.sh
```

### Create the 7-pod.sh script

#### Check the documentation

```shell
k top pod -h
--containers=false:
    If present, print usage of containers within a pod.
```

#### Create the script

```shell
echo 'kubectl top pod --containers=true' > 7-pod.sh
chmod u+x 7-pod.sh
./7-pod.sh
```

