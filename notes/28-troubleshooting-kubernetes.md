# Troubleshooting Kubernetes

## Understanding Application Logs

- `Container engines` like `containerd` are designed to support logging and usually write all their output to standard output (`stdout`) and standard error (`stderr`) streams to a file located in the directory `/var/log/containers`.

## Create a Single Node Cluster

Follow the instructions on [Create Cluster](00-create-cluster.md#create-a-single-node) document to `Create a Single Node`.

## Exam Task

### Create a Namespace

```shell
k create ns db08328
namespace/db08328 created
```

### List the Namespaces

```shell
k get ns
NAME                 STATUS   AGE
db08328              Active   23s
default              Active   33s
kube-node-lease      Active   33s
kube-public          Active   33s
kube-system          Active   33s
local-path-storage   Active   30s
```

### Change the context to the namespace db08328

```shell
k config set-context --current --namespace db08328
Context "kind-cka" modified.
```

### Create a Deployment

```shell
k create deploy mysql --image mysql:8
deployment.apps/mysql created
```

### List the Pods

```shell
k get pods
NAME                     READY   STATUS   RESTARTS      AGE
mysql-56787b9bcf-86zrc   0/1     Error    2 (22s ago)   31s

k get pods
NAME                     READY   STATUS             RESTARTS      AGE
mysql-56787b9bcf-86zrc   0/1     CrashLoopBackOff   3 (36s ago)   86s
```

#### Possible Statuses of a Pod

- CrashLoopBackOff
- OOMKilled
- ErrImagePull
- ImagePullBackoff
- FailedScheduling
- NonZeroExitCode
- CreateContainerConfigError

### Inspect the logs of the Pod

```shell
k logs mysql-56787b9bcf-86zrc
2024-09-24 13:08:45+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.4.2-1.el9 started.
2024-09-24 13:08:45+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2024-09-24 13:08:45+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.4.2-1.el9 started.
2024-09-24 13:08:45+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
    You need to specify one of the following as an environment variable:
    - MYSQL_ROOT_PASSWORD
    - MYSQL_ALLOW_EMPTY_PASSWORD
    - MYSQL_RANDOM_ROOT_PASSWORD
```

This log is telling us that we need to set the password using one of the environment variables.

### Edit the Deployment

```shell
k edit deploy mysql
deployment.apps/mysql edited
```

Add the following environment variable in the container:

```yaml
containers:
- env:
  - name: MYSQL_ROOT_PASSWORD
    value: password
```

### List the Pods

```shell
k get pod
NAME                     READY   STATUS    RESTARTS   AGE
mysql-756d456979-cwmqv   1/1     Running   0          42s
```

## Create a Multi Container Pod

```shell
k apply -f yaml-definitions/multi-container-pod-for-logging.yaml
pod/busybox created
```

### List the Pod

```shell
k get pod
NAME                     READY   STATUS    RESTARTS   AGE
busybox                  2/2     Running   0          13s
mysql-756d456979-cwmqv   1/1     Running   0          41m
```

As you can see the `busybox` Pod has two containers (`READY 2/2`).

### View the container logs

The pod has two containers called `busybox` and `sidecar`.

#### Logs of the busybox container

```shell
k logs busybox -c busybox
Tue Sep 24 13:56:40 UTC 2024: I am a busybox container
Tue Sep 24 13:56:45 UTC 2024: I am a busybox container
Tue Sep 24 13:56:50 UTC 2024: I am a busybox container
Tue Sep 24 13:56:55 UTC 2024: I am a busybox container
Tue Sep 24 13:57:00 UTC 2024: I am a busybox container
Tue Sep 24 13:57:05 UTC 2024: I am a busybox container
Tue Sep 24 13:57:10 UTC 2024: I am a busybox container
```

#### Logs of the sidecar container

```shell
k logs busybox -c sidecar
Tue Sep 24 13:56:41 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:46 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:51 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:56 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:01 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:06 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:11 UTC 2024: I am a sidecar container
```

#### Logs of all the containers in the pod

```shell
k logs busybox --all-containers
Tue Sep 24 13:56:41 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:46 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:51 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:56 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:01 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:06 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:11 UTC 2024: I am a sidecar container
Tue Sep 24 13:57:16 UTC 2024: I am a sidecar container
Tue Sep 24 13:56:40 UTC 2024: I am a busybox container
Tue Sep 24 13:56:45 UTC 2024: I am a busybox container
Tue Sep 24 13:56:50 UTC 2024: I am a busybox container
Tue Sep 24 13:56:55 UTC 2024: I am a busybox container
Tue Sep 24 13:57:00 UTC 2024: I am a busybox container
Tue Sep 24 13:57:05 UTC 2024: I am a busybox container
Tue Sep 24 13:57:10 UTC 2024: I am a busybox container
```

#### Streaming the logs

```shell
k logs busybox --all-containers -f
```

Press `Control-C` to get the prompt back.

## Cluster Component Failure

- Control Plane components such as the scheduler, controller manager, etcd, and API Server, all run as Pods on the control plane node in the kube-system namespace
- The YAML manifests for these control plane components are located in the `/etc/kubernetes/manifests` directory in the control plane node
- The are called static Pods because the scheduler it not aware of these Pods

### Create single cluster node

Use the instructions to create a single cluster node that you can find [here](00-create-cluster.md#create-a-single-node).

### Create a namespace

```shell
k create namespace ee8881
namespace/ee8881 created
```

### Change the context namespace

```shell
k config set-context --current --namespace ee8881
Context "kind-cka" modified.
```

### Create a Deployment in the Namespace

```shell
k create deploy prod-app --image nginx
deployment.apps/prod-app created
```

### Get the Deployment and Pods

```shell
k get deploy,pod
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prod-app   0/1     1            0           40s

NAME                            READY   STATUS              RESTARTS   AGE
pod/prod-app-678bf6d75b-rjsfd   0/1     ContainerCreating   0          40s
```

### Simulate a control plane failure

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/# curl https://raw.githubusercontent.com/chadmcrowell/acing-the-cka-exam/main/ch_08/kube-scheduler.yaml --silent --output /etc/kubernetes/manifests/kube-scheduler.yaml
exit
```

### Scale the Deployment from one replica to three

```shell
k scale deploy prod-app --replicas 3
deployment.apps/prod-app scaled
```

### Validate the Pods

```shell
k get pods
NAME                        READY   STATUS    RESTARTS   AGE
prod-app-678bf6d75b-mx89m   0/1     Pending   0          37s
prod-app-678bf6d75b-nlw92   0/1     Pending   0          37s
prod-app-678bf6d75b-rjsfd   1/1     Running   0          6m30s
```

New Pods should be on `Pending` state.

### Get the Scheduler Pods

```shell
k get pods -n kube-system
NAME                                        READY   STATUS             RESTARTS      AGE
coredns-76f75df574-fmsp8                    1/1     Running            0             17m
coredns-76f75df574-wgn8v                    1/1     Running            0             17m
etcd-cka-control-plane                      1/1     Running            0             17m
kindnet-skc5h                               1/1     Running            0             17m
kube-apiserver-cka-control-plane            1/1     Running            0             17m
kube-controller-manager-cka-control-plane   1/1     Running            0             17m
kube-proxy-bcjtd                            1/1     Running            0             17m
kube-scheduler-cka-control-plane            0/1     CrashLoopBackOff   5 (21s ago)   3m35s
```

### Get the Scheduler Logs

```shell
k logs kube-scheduler-cka-control-plane -n kube-system | tail -2

Error: unknown flag: --kkubeconfig
```

There is misspelling in the flag.

### Connect to the control plane node

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/#
```

### Install VIM

```shell
root@cka-control-plane:/# apt update && apt install vim -y
```

### Go to Kubernetes Manifest Directory

```shell
root@cka-control-plane:/# cd /etc/kubernetes/manifests/
root@cka-control-plane:/etc/kubernetes/manifests# 
```

### Edit the kube-scheduler.yaml file

```shell
vim kube-scheduler.yaml
```

### Search for kkubeconfig

```shell
# The line should be:
- --kubeconfig=/etc/kubernetes/scheduler.conf
# Remove the additional k and save the file
exit
```

### Validate the Pods

```shell
k get pods
NAME                        READY   STATUS    RESTARTS   AGE
prod-app-678bf6d75b-mx89m   1/1     Running   0          12m
prod-app-678bf6d75b-nlw92   1/1     Running   0          12m
prod-app-678bf6d75b-rjsfd   1/1     Running   0          17m
```

### Validate the scheduler state

```shell
k get pods -n kube-system

NAME                                        READY   STATUS    RESTARTS   AGE
coredns-76f75df574-fmsp8                    1/1     Running   0          27m
coredns-76f75df574-wgn8v                    1/1     Running   0          27m
etcd-cka-control-plane                      1/1     Running   0          27m
kindnet-skc5h                               1/1     Running   0          27m
kube-apiserver-cka-control-plane            1/1     Running   0          27m
kube-controller-manager-cka-control-plane   1/1     Running   0          27m
kube-proxy-bcjtd                            1/1     Running   0          27m
kube-scheduler-cka-control-plane            1/1     Running   0          38s
```
