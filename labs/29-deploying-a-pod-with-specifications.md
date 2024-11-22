# Question 29 - Deploying a Pod with Specifications - 6%

## Use context

```shell
kubectl config use kind-k8s-c5
```

## Task Definition

- **Pod Name:** web-pod.
- **Image:** httpd.
- **Node:** k8s-c4-worker.
- **Note:** Do not modify any settings on master and worker nodes.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the Pod

```shell
k run web-pod --image=httpd --dry-run=client -o yaml > 29.yaml
```

#### Content of the file 29.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: web-pod
  name: web-pod
spec:
  containers:
  - image: httpd
    name: web-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Remove the following lines:
- creationTimestamp: null
- status: {}

### Apply the file 29.yaml in the cluster

```shell
k apply -f 29.yaml
pod/web-pod created
```

### Check the Pod

```shell
k get pod web-pod -o wide
NAME      READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
web-pod   0/1     Pending   0          8s    <none>   <none>   <none>           <none>
```

### List the nodes

```shell
k get nodes
NAME                   STATUS   ROLES           AGE   VERSION
k8s-c5-control-plane   Ready    control-plane   19m   v1.29.0
k8s-c5-worker          Ready    <none>          18m   v1.29.0
```

### Validate if k8s-c5-worker node has taints

```shell
k get node k8s-c5-worker -o jsonpath='{.spec.taints}'
[{"effect":"NoSchedule","key":"node-role.kubernetes.io/node"}]% 
```

The node `k8s-c5-worker` has a `Taint` that `web-pod` does not tolerate.

### Search for taint in the documentation

- Search for `taint` in the Kubernetes documentation and click on `Taints and Tolerations | Kubernetes` link.
- Scroll down until `pods/pod-with-toleration.yaml` example and copy the toleration section, see that it is at the same level of `contatiners:`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "example-key"
    operator: "Exists"
    effect: "NoSchedule"
```

### Modify the 29.yaml definition file

Add the following `tolerations:` definition to the file:

```yaml
containers:
...
tolerations:
- key: "node-role.kubernetes.io/node"
  operator: "Exists"
  effect: "NoSchedule"
```

Complete `29.yaml` definition:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: web-pod
  name: web-pod
spec:
  containers:
  - image: httpd
    name: web-pod
    resources: {}
  tolerations:
  - key: "node-role.kubernetes.io/node"
    operator: "Exists"
    effect: "NoSchedule"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

### Apply the file

```shell
k apply -f 29.yaml
pod/web-pod configured
```

### Check the Pod

```shell
k get pod web-pod -o wide
NAME      READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
web-pod   1/1     Running   0          13m   10.244.1.3   k8s-c5-worker   <none>           <none>
```

</details>