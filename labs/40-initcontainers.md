# Question 40 - Init Containers - 4%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Add an `init container` named `init-container` (which has been defined in the spec file in `yaml-definitions/web-pod.yaml`).
- The init container should create an empty file named `/workdir/conf.txt`.
- If `/workdir/conf.txt` is not detected, the Pod should exit.
- Once the spec file has been updated with the init container definition, the Pod should be created.

## Solution

<details>
  <summary>Show the solution</summary>

### Copy the web-pod.yaml to 40.yaml

```shell
cp yaml-definitions/web-pod.yaml 40.yaml
```

### List the content of 40.yaml file

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  volumes:
    - name: workdir
      emptyDir: {}
  containers:
  - name: web-pod
    image: gcr.io/google-containers/alpine
    command: ["/bin/sh", "-c", "if [ -f /workdir/conf.txt ]; then sleep 10000; else exit 1; fi"]
    volumeMounts:
      - mountPath: /workdir
        name: workdir
```

- Search for `init container` in the documentation.
- Select the `Init Containers` link.
- Copy the first example.

```yaml
initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
```

### Append the initcontainer definition to 40.yaml

- The `name:` should be `init-container`.
- In the `command:` use `touch /workdir/conf.txt` to create the config file.
- Add the `volumeMounts:` section to the `initcontainers`.
- Set the image name of the initcontainer to `gcr.io/google-containers/busybox`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  volumes:
    - name: workdir
      emptyDir: {}
  containers:
  - name: web-pod
    image: gcr.io/google-containers/nginx
    command: ["/bin/sh", "-c", "if [ -f /workdir/conf.txt ]; then sleep 10000; else exit 1; fi"]
    volumeMounts:
      - mountPath: /workdir
        name: workdir
  initContainers:
    - name: init-container
      image: gcr.io/google-containers/busybox
      command: [ 'sh', '-c', "touch /workdir/conf.txt" ]
      volumeMounts:
        - mountPath: /workdir
          name: workdir
```

### Apply the 40.yaml file

```shell
k apply -f 40.yaml
pod/web-pod created
```


### List the Pods

```shell
k get pods
pod/web-pod created
NAME                        READY   STATUS     RESTARTS   AGE
docs-app-5f78c98b7b-5hnv8   1/1     Running    0          46m
docs-app-5f78c98b7b-lhhmb   1/1     Running    0          46m
docs-app-5f78c98b7b-vscfl   1/1     Running    0          46m
web-pod                     0/1     Init:0/1   0          0s
```

### Wait some time and list the Pods

```shell
k get pods
NAME                        READY   STATUS    RESTARTS   AGE
docs-app-5f78c98b7b-5hnv8   1/1     Running   0          50m
docs-app-5f78c98b7b-lhhmb   1/1     Running   0          50m
docs-app-5f78c98b7b-vscfl   1/1     Running   0          50m
web-pod                     1/1     Running   0          4s
```

### Describe the Pod

Look at the section `Init Containers:`.

```shell
k describe pod web-pod
Name:             web-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             k8s-c2-worker2/172.18.0.7
Start Time:       Sun, 24 Nov 2024 22:19:46 -0500
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.1.7
IPs:
  IP:  10.244.1.7
Init Containers:
  init-container:
    Container ID:  containerd://2bf5b2cbbbe4d903118a9f31179e298f29dd213990689725a832b094256b719e
    Image:         gcr.io/google-containers/busybox
    Image ID:      sha256:36a4dca0fe6fb2a5133dc11a6c8907a97aea122613fa3e98be033959a0821a1f
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      touch /workdir/conf.txt
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 24 Nov 2024 22:19:48 -0500
      Finished:     Sun, 24 Nov 2024 22:19:48 -0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wkntr (ro)
      /workdir from workdir (rw)
Containers:
  web-pod:
    Container ID:  containerd://e7614f3b87a2309b95bf8e90c20f0b2b8274ee01704817545014ec8cbe9ade7f
    Image:         gcr.io/google-containers/nginx
    Image ID:      gcr.io/google-containers/nginx@sha256:f49a843c290594dcf4d193535d1f4ba8af7d56cea2cf79d1e9554f077f1e7aaa
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      if [ -f /workdir/conf.txt ]; then sleep 10000; else exit 1; fi
    State:          Running
      Started:      Sun, 24 Nov 2024 22:19:49 -0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wkntr (ro)
      /workdir from workdir (rw)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  workdir:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-wkntr:
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
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  72s   default-scheduler  Successfully assigned default/web-pod to k8s-c2-worker2
  Normal  Pulling    72s   kubelet            Pulling image "gcr.io/google-containers/busybox"
  Normal  Pulled     70s   kubelet            Successfully pulled image "gcr.io/google-containers/busybox" in 1.513s (1.513s including waiting)
  Normal  Created    70s   kubelet            Created container init-container
  Normal  Started    70s   kubelet            Started container init-container
  Normal  Pulling    69s   kubelet            Pulling image "gcr.io/google-containers/nginx"
  Normal  Pulled     69s   kubelet            Successfully pulled image "gcr.io/google-containers/nginx" in 413ms (413ms including waiting)
  Normal  Created    69s   kubelet            Created container web-pod
  Normal  Started    69s   kubelet            Started container web-pod
```

</details>