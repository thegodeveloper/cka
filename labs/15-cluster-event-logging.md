# Question 15 - Cluster Event Logging - 3%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Write a command into `cluster-events.sh` which shows the latest events in the whole cluster, ordered by time. Use `kubectl` for it.
- Now kill the `kube-proxy` Pod running on node `k8s-c2-worker` and write the events into `pod_kill.log`.
- Finally kill the containerd container of the `kube-proxy` Pod on node `k8s-c2-worker` and write the events into `container_kill.log`. 

## Solution

<details>
  <summary>Show the solution</summary>

### Write the command cluster-events.sh

```shell
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

```shell
echo 'kubectl get events -A --sort-by=.metadata.creationTimestamp' > cluster-events.sh
cat cluster-events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
chmod u+x cluster-events.sh
./cluster-events.sh
```

### Kill kube-proxy Pod in k8s-c2-worker node

```shell
k -n kube-system get pod -o wide | grep kube-proxy
kube-proxy-b2wb5                            1/1     Running   0          21m   172.18.0.3   k8s-c2-worker2         <none>           <none>
kube-proxy-jf4d2                            1/1     Running   0          21m   172.18.0.4   k8s-c2-control-plane   <none>           <none>
kube-proxy-x6r2j                            1/1     Running   0          21m   172.18.0.2   k8s-c2-worker          <none>           <none>
```

```shell
k -n kube-system delete pod kube-proxy-x6r2j
pod "kube-proxy-x6r2j" deleted
```

```shell
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

```shell
vi pod_kill.log

And add the information
```

```shell
cat pod_kill.log
kube-system          90s         Normal    Killing                   pod/kube-proxy-x6r2j                            Stopping container kube-proxy
kube-system          89s         Normal    Pulled                    pod/kube-proxy-7ln7q                            Container image "registry.k8s.io/kube-proxy:v1.29.0" already present on machine
kube-system          89s         Normal    Started                   pod/kube-proxy-7ln7q                            Started container kube-proxy
kube-system          89s         Normal    Created                   pod/kube-proxy-7ln7q                            Created container kube-proxy
default              89s         Normal    Starting                  node/k8s-c2-worker                                 
kube-system          89s         Normal    Scheduled                 pod/kube-proxy-7ln7q                            Successfully assigned kube-system/kube-proxy-7ln7q to k8s-c2-worker
kube-system          89s         Normal    SuccessfulCreate          daemonset/kube-proxy                            Created pod: kube-proxy-7ln7q
```

### kill the containerd container of the kube-proxy Pod on node k8s-c2-worker

```shell
k -n kube-system get pod -o wide | grep kube-proxy
kube-proxy-7ln7q                            1/1     Running   0          6m2s   172.18.0.2   k8s-c2-worker          <none>           <none>
kube-proxy-b2wb5                            1/1     Running   0          27m    172.18.0.3   k8s-c2-worker2         <none>           <none>
kube-proxy-jf4d2                            1/1     Running   0          27m    172.18.0.4   k8s-c2-control-plane   <none>           <none>
```

```shell
docker exec -it k8s-c2-worker bash
root@k8s-c2-worker:/# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD
87fb11a3ffd82       0c3491790de4f       9 minutes ago       Running             kube-proxy          0                   91007ee90200c       kube-proxy-7ln7q
6dff5769b90fb       b18bf71b941ba       30 minutes ago      Running             kindnet-cni         0                   049849de5bba7       kindnet-bhnzc
```

```shell
root@k8s-c2-worker:/# crictl stop 87fb11a3ffd82
87fb11a3ffd82
root@k8s-c2-worker:/# crictl rm 87fb11a3ffd82
87fb11a3ffd82
```

```shell
vim container_kill.log
add the information
```

```shell
cat container_kill.log
kube-system          81s         Normal    Pulled                    pod/kube-proxy-7ln7q                            Container image "registry.k8s.io/kube-proxy:v1.29.0" already present on machine
kube-system          80s         Normal    Started                   pod/kube-proxy-7ln7q                            Started container kube-proxy
default              80s         Normal    Starting                  node/k8s-c2-worker
```
</details>
