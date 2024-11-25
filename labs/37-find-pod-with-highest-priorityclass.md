# Question 37 - Find pod with highest Priority Class - 2%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Find a Pod with the highest `priority` in Namespace `management` and delete it.

## Solution

<details>
  <summary>Show the solution</summary>

### List the Pods in management Namespace

```shell
k -n management get pod
NAME        READY   STATUS    RESTARTS   AGE
nginx-app   1/1     Running   0          83s
nginx-web   1/1     Running   0          83s
```

### Get the Priority Classes

```shell
k get priorityclasses
NAME                      VALUE        GLOBAL-DEFAULT   AGE
level2                    2000000      false            2m40s
level3                    3000000      false            2m40s
system-cluster-critical   2000000000   false            107m
system-node-critical      2000001000   false            107m
```

### Get the Priority Class assigned to the pod in management Namespace

```shell
k -n management get pod -o yaml | grep -i priority -B 20
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"appserver"},"name":"nginx-app","namespace":"management"},"spec":{"containers":[{"image":"gcr.io/google-containers/nginx","imagePullPolicy":"IfNotPresent","name":"nginx"}],"priorityClassName":"level3"}}
--
      app: appserver
    name: nginx-app
    namespace: management
    resourceVersion: "12692"
    uid: 8a5ce9ab-c80d-40c0-a8eb-d11549130dda
  spec:
    containers:
    - image: gcr.io/google-containers/nginx
      imagePullPolicy: IfNotPresent
      name: nginx
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-ggbxf
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: k8s-c1-worker2
    preemptionPolicy: PreemptLowerPriority
    priority: 3000000
    priorityClassName: level3
--
      ready: true
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2024-11-25T01:23:40Z"
    hostIP: 172.18.0.2
    hostIPs:
    - ip: 172.18.0.2
    phase: Running
    podIP: 10.244.1.18
    podIPs:
    - ip: 10.244.1.18
    qosClass: BestEffort
    startTime: "2024-11-25T01:23:40Z"
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"webserver"},"name":"nginx-web","namespace":"management"},"spec":{"containers":[{"image":"gcr.io/google-containers/nginx","imagePullPolicy":"IfNotPresent","name":"nginx"}],"priorityClassName":"level2"}}
--
      app: webserver
    name: nginx-web
    namespace: management
    resourceVersion: "12693"
    uid: 00574c26-255d-4cbc-8efb-875ed6a4b60d
  spec:
    containers:
    - image: gcr.io/google-containers/nginx
      imagePullPolicy: IfNotPresent
      name: nginx
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-kv62n
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: k8s-c1-worker2
    preemptionPolicy: PreemptLowerPriority
    priority: 2000000
    priorityClassName: level2
```

The Pod `nginx-app` has the highest priority.

### Delete the nginx-app Pod

```shell
k -n management delete pod nginx-app
pod "nginx-app" deleted
```

</details>