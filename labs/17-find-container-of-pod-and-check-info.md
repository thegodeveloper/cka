# Find Container of Pod & Check Info

## Task Definition

- Create a namespace `project-tiger`.
- Create a Pod named `tigers-reunite` in namespace `project-tiger` of image `httpd:2.4.41-alpine` with labels `pod=container` and `container=pod`.
- Find out which node the Pod is scheduled.
- SSH into that node and find the containerd container belonging to that Pod.
- Using command `crictl`:
  - Write the ID of the container and the `info.runtimeType` into `pod-container.txt`.
  - Write the logs of the container into `pod-container.log`.

## Solution

### Create a namespace

```shell
k create ns project-tiger
```

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
devops-pool-g8373
```

