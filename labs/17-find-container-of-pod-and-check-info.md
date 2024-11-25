# Question 17 - Find Container of Pod & Check Info - 3%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create a Pod named `tigers-reunite` in namespace `project-tiger` of image `httpd:2.4.41-alpine` with labels `pod=container` and `container=pod`.
- Find out which node the Pod is scheduled.
- SSH into that node and find the containerd container belonging to that Pod.
- Using command `crictl`:
  - Write the ID of the container and the `info.runtimeType` into `pod-container.txt`.
  - Write the logs of the container into `pod-container.log`.

## Solution

<details>
  <summary>Show the solution</summary>

### Create tigers-reunite Pod

```shell
k run --image=httpd:2.4.41-alpine -l "pod=container,container=pod" -n project-tiger tigers-reunite -o yaml --dry-run=client > 17.yaml
```

```shell
k apply -f 17.yaml
pod/tigers-reunite created
```

### Find out which node the Pod is scheduled

```shell
k -n project-tiger get pod tigers-reunite -o jsonpath='{.spec.nodeName}'
k8s-c1-worker2
```

### Get the container ID and runtimeType

```shell
docker exec -it k8s-c1-worker2 bash
root@k8s-c1-worker2:/# crictl ps | grep tigers-reunite
cc5de89e8bef6       54b0995a63052       10 minutes ago      Running             tigers-reunite            0                   afe418e658adc       tigers-reunite
```

```shell
docker exec -it k8s-c1-worker2 bash
root@k8s-c1-worker2:/# crictl inspect cc5de89e8bef6 | grep runtimeType
    "runtimeType": "io.containerd.runc.v2",
```

### Write the information to pod-container.log

```shell
echo 'cc5de89e8bef6 io.containerd.runc.v2' > pod-container.log
```

</details>
