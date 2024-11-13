# Etcd Snapshot Save and Restore - 8%

## Use context

```shell
kubectl config use-context kind-ks8-c3
```

## Task Definition

- Make a backup of `etcd` running on `k8s-c3-control-plane` and save it on the master node at `/tmp/etcd-backup.db`.
- Then create a Pod of your kind in the cluster.
- Finally restore the backup, confirm the cluster is still working and that the created Pod is no longer in the cluster. 

## Solution

<details>
  <summary>Show the solution</summary>

### Log in the k8s-c3-control-plane node

```shell
docker exec -it k8s-c3-control-plane bash
root@k8s-c3-control-plane:/# 
```

### Create Etcd Backup

Create a `snapshot` of `etcd`:

```shell
root@k8s-c3-control-plane:/# ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db
{"level":"info","ts":"2024-11-13T14:33:29.285452Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/tmp/etcd-backup.db.part"}
```

The command get stuck with that output. Cancel the process with CTRL+c.

We need to authenticate ourselves. For the necessary information check the `etc` manifest:

```shell
cat /etc/kubernetes/manifests/etcd.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/etcd.advertise-client-urls: https://172.18.0.10:2379
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=https://172.18.0.10:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt                           # use
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --experimental-initial-corrupt-check=true
    - --experimental-watch-progress-notify-interval=5s
    - --initial-advertise-peer-urls=https://172.18.0.10:2380
    - --initial-cluster=k8s-c3-control-plane=https://172.18.0.10:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key                            # use
    - --listen-client-urls=https://127.0.0.1:2379,https://172.18.0.10:2379      # use
    - --listen-metrics-urls=http://127.0.0.1:2381
    - --listen-peer-urls=https://172.18.0.10:2380
    - --name=k8s-c3-control-plane
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt                    # use
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    image: registry.k8s.io/etcd:3.5.10-0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /health?exclude=NOSPACE&serializable=true
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: etcd
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /health?serializable=false
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
status: {}
```

### The apiserver is connecting to etcd -- Tip!!!

```
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
```

### Create the etcd backup

```shell
oot@k8s-c3-control-plane:/# ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
> --cacert /etc/kubernetes/pki/etcd/ca.crt \
> --cert /etc/kubernetes/pki/etcd/server.crt \          
> --key /etc/kubernetes/pki/etcd/server.key
{"level":"info","ts":"2024-11-13T15:44:03.628343Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/tmp/etcd-backup.db.part"}
{"level":"info","ts":"2024-11-13T15:44:03.634368Z","logger":"client","caller":"v3@v3.5.17/maintenance.go:212","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2024-11-13T15:44:03.634417Z","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":"2024-11-13T15:44:03.648739Z","logger":"client","caller":"v3@v3.5.17/maintenance.go:220","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2024-11-13T15:44:03.648815Z","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"2.2 MB","took":"now"}
{"level":"info","ts":"2024-11-13T15:44:03.648850Z","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/tmp/etcd-backup.db"}
Snapshot saved at /tmp/etcd-backup.db
```

```shell
root@k8s-c3-control-plane:/# ls -l /tmp/etcd-backup.db 
-rw------- 1 root root 2166816 Nov 13 15:44 /tmp/etcd-backup.db
```

### Create a Pod in the cluster

```shell
root@k8s-c3-control-plane:/# kubectl run nginx-test --image=nginx
pod/nginx-test created
root@k8s-c3-control-plane:/# kubectl get pod nginx-test
NAME         READY   STATUS    RESTARTS   AGE
nginx-test   1/1     Running   0          9s
```

### Restore the Etcd Backup

#### Stop controlplane components

```shell
root@k8s-c3-control-plane:/# cd /etc/kubernetes/manifests/
root@k8s-c3-control-plane:/etc/kubernetes/manifests# ls -la
total 28
drwxr-xr-x 1 root root 4096 Nov 13 14:29 .
drwxr-xr-x 1 root root 4096 Nov 13 14:29 ..
-rw------- 1 root root 2416 Nov 13 14:29 etcd.yaml
-rw------- 1 root root 3901 Nov 13 14:29 kube-apiserver.yaml
-rw------- 1 root root 3430 Nov 13 14:29 kube-controller-manager.yaml
-rw------- 1 root root 1463 Nov 13 14:29 kube-scheduler.yaml
root@k8s-c3-control-plane:/etc/kubernetes/manifests# ls -l ../
total 44
-rw------- 1 root root 5648 Nov 13 14:29 admin.conf
-rw------- 1 root root 5663 Nov 13 14:29 controller-manager.conf
-rw------- 1 root root 2016 Nov 13 14:29 kubelet.conf
drwxr-xr-x 1 root root 4096 Nov 13 14:29 manifests
drwxr-xr-x 3 root root 4096 Nov 13 14:29 pki
-rw------- 1 root root 5611 Nov 13 14:29 scheduler.conf
-rw------- 1 root root 5672 Nov 13 14:29 super-admin.conf
root@k8s-c3-control-plane:/etc/kubernetes/manifests# mv *.yaml ../
```

#### Monitor crictl

```shell
root@k8s-c3-control-plane:/etc/kubernetes/manifests# watch crictl ps
```

#### Restore the etcd backup into a specific directory

```shell
root@k8s-c3-control-plane:/etc/kubernetes/manifests# ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
> --data-dir /var/lib/etcd-backup \
> --cacert /etc/kubernetes/pki/etcd/ca.crt \
> --cert /etc/kubernetes/pki/etcd/server.crt \
> --key /etc/kubernetes/pki/etcd/server.key
Deprecated: Use `etcdutl snapshot restore` instead.

2024-11-13T15:53:57Z	info	snapshot/v3_snapshot.go:265	restoring snapshot	{"path": "/tmp/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap", "initial-memory-map-size": 0}
2024-11-13T15:53:57Z	info	membership/store.go:141	Trimming membership information from the backend...
2024-11-13T15:53:57Z	info	membership/cluster.go:421	added member	{"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"]}
2024-11-13T15:53:57Z	info	snapshot/v3_snapshot.go:293	restored snapshot	{"path": "/tmp/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap", "initial-memory-map-size": 0}
```

#### Update the location of the etcd DB

```shell
root@k8s-c3-control-plane:~# vim /etc/kubernetes/etcd.yaml
```

Change the following:

```yaml
- hostPath:
    path: /var/lib/etcd
    type: DirectoryOrCreate
  name: etcd-data
```

```yaml
- hostPath:
    path: /var/lib/etcd-backup
    type: DirectoryOrCreate
  name: etcd-data
```

#### Move controlplane yaml definitions into manifests directory

```shell
root@k8s-c3-control-plane:~# cd /etc/kubernetes/
root@k8s-c3-control-plane:/etc/kubernetes# ls -l *.yaml
-rw------- 1 root root 2423 Nov 13 15:59 etcd.yaml
-rw------- 1 root root 3901 Nov 13 14:29 kube-apiserver.yaml
-rw------- 1 root root 3430 Nov 13 14:29 kube-controller-manager.yaml
-rw------- 1 root root 1463 Nov 13 14:29 kube-scheduler.yaml
root@k8s-c3-control-plane:/etc/kubernetes# mv *.yaml manifests/
```

### Validate if the Pod exist

```shell
root@k8s-c3-control-plane:~# kubectl get pod
No resources found in default namespace.
```

</details>
