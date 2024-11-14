# Question 7 - Node and Pod Resource Usage - 1%

## Use Context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- The metrics server should be installed in the cluster.
- Create a `7-node.sh` to show `node` resource usage.
- Create a `7-pod.sh` to show `pod` and their container resource usage.

## Solution

<details>
  <summary>Show the solution</summary>

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
</details>
