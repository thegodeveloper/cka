# Question 28 - Pod Troubleshooting - 3%

## Use context

```shell
kubectl config use kind-k8s-c4
```

## Task Definition

- You can find a Pod named `task-pv-pod` in the default namespace.
- Check the status of the Pod and troubleshoot.
- You can recreate the Pod if you want.

## Solution

<details>
  <summary>Show the solution</summary>

### Check the Pod

```shell
k get pod task-pv-pod
NAME          READY   STATUS    RESTARTS   AGE
task-pv-pod   0/1     Pending   0          7m43s
```

### Describe the Pod configuration

```shell
k describe pod task-pv-pod

Name:             task-pv-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           <none>
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Containers:
  task-pv-container:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /usr/share/nginx/html from task-pv-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jrhfb (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  task-pv-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  task-pv-claimm
    ReadOnly:   false
  kube-api-access-jrhfb:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age                    From               Message
  ----     ------            ----                   ----               -------
  `Warning  FailedScheduling  3m43s (x2 over 8m57s)  default-scheduler  0/2 nodes are available: persistentvolumeclaim "task-pv-claimm" not found`. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
```

Inspecting the output you can see the following warning:

```shell
`Warning  FailedScheduling  3m43s (x2 over 8m57s)  default-scheduler  0/2 nodes are available: persistentvolumeclaim "task-pv-claimm" not found`.
```

`persistentVolumeclaim "task-pv-claimm"` not found.

### Check the Persistent Volume

```shell
k get pv 
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
task-pv-volume   10Gi       RWO            Retain           Bound    default/task-pv-claim   manual         <unset>                          14m
```

### Check the Persistent Volume Claim

```shell
k get pvc
NAME            STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
task-pv-claim   Bound    task-pv-volume   10Gi       RWO            manual         <unset>                 14m
```

The Persistent Volume Claim name is different.

### Edit the Pod Configuration

```shell
k edit pod task-pv-pod
```

Search for `claimName:` and change the name of the Persistent Volume Claim to `task-pv-claim`.

When save the change take note of the file saved in the temporal folder.

A copy of your changes has been stored to "/tmp/kubectl-edit-3666025755.yaml"

### Check the file

```shell
ls -l /tmp/kubectl-edit-3666025755.yaml
-rw------- 1 william william 4420 nov 22 12:56 /tmp/kubectl-edit-3666025755.yaml
```

### Recreate the Pod

##### Delete the Pod

```shell
k delete pod task-pv-pod
pod "task-pv-pod" deleted
```

#### Create the Pod

```shell
k apply -f /tmp/kubectl-edit-3666025755.yaml
pod/task-pv-pod created
```

### Check the Pod

```shell
k get pod task-pv-pod
NAME          READY   STATUS    RESTARTS   AGE
task-pv-pod   1/1     Running   0          38s
```

</details>