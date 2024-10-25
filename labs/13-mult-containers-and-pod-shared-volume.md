# Multi Container and Pod Shared Volume - 4%

## Use Context kind-cka

```shell
k config use-context kind-cka
Switched to context "kind-cka".
```

## Task Definition

- Create a Pod named `multi-container-playground` in Namespace `default` with three containers.
- Name the containers `c1`, `c2` and `c3`.
- There should be a volume attached to that Pod and mounted into every container, but the volume shouldn't be persisted or shared with other Pods.
- Container `c1` should be of image `ningx:1.17.6-alpine` and have the name of the node where its Pod is running available as environment variable `MY_NODE_NAME`.
- Container `c2` should be of image `busybox:1.31.1` and write the output of the `date` command every second in the shared volume into file `date.log`.
- You can use `while true; do date >> /your/vol/path/date.log; sleep 1; done`.
- Container `c3` should be of image `busybox:1.31.1` and constantly send the content of file `date.log` from the shared volume to stdout.
- You can use `tail -f /your/vol/path/date.log`.
- Check the logs of container `c3` to confirm the correct setup.

## Solution

### Create the Pod YAML Template

```shell
k run multi-container-playground --image=nginx:1.17.6-alpine -o yaml --dry-run=client > 13.yaml
```

### YAML Definition Content

The important point in this task is to follow the requirements step by step.
- Create the first container with its requirements, env variable, know how to pass the Node Name.
- Define the `volumeMounts` and the `volume` definition of type `emptyDir`.
- Then create the second container with the `command` and `volumeMounts` definition.
- The third container is similar to the second one, pay attention to the `command` definition.
- Looks difficult but it is not.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi-container-playground
  name: multi-container-playground
spec:
  containers:
  - image: nginx:1.17.6-alpine
    name: c1
    env:
      - name: MY_NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
    volumeMounts:
      - mountPath: /vol
        name: vol
    resources: {}
  - image: busybox:1.31.1
    name: c2
    command: ["sh", "-c", "while true; do date >> /vol/date.log; sleep 1; done"]
    volumeMounts:
    - mountPath: /vol
      name: vol
  - image: busybox:1.31.1
    name: c3
    command: ["sh", "-c", "tail -f /vol/date.log"]
    volumeMounts:
      - mountPath: /vol
        name: vol
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
    - name: vol
      emptyDir: {}
```

### Apply the YAML Definition

```shell
k apply -f 13.yaml
pod/multi-container-playground created
```

### Check the Pod

```shell
k get pod multi-container-playground
NAME                         READY   STATUS    RESTARTS   AGE
multi-container-playground   3/3     Running   0          51s
```

### Check the container c1

Check if container `c1` has the requested node name as env variable:

```shell
k exec multi-container-playground -c c1 -- env | grep MY
MY_NODE_NAME=cka-worker2
```

### Check the container c3

```shell
k logs multi-container-playground -c c3
Fri Oct 25 02:01:54 UTC 2024
Fri Oct 25 02:01:55 UTC 2024
Fri Oct 25 02:01:56 UTC 2024
Fri Oct 25 02:01:57 UTC 2024
Fri Oct 25 02:01:58 UTC 2024
Fri Oct 25 02:01:59 UTC 2024
Fri Oct 25 02:02:00 UTC 2024
```

## Clean the Environment

### Delete the Pod

```shell
k delete pod multi-container-playground
pod "multi-container-playground" deleted
```