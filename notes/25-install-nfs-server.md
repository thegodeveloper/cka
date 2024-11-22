# Install NFS Server in Kind Kubernetes Cluster

## Installing NFS Server Using Helm

### Installing the Helm Repo

```shell
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
"nfs-ganesha-server-and-external-provisioner" has been added to your repositories
```

### Installing the Helm Chart

```shell
helm install nfs-ganesha-server nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner

NAME: nfs-ganesha-server
LAST DEPLOYED: Mon Sep 23 19:27:27 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```

### List the Helm Chart

```shell
helm list

NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
nfs-ganesha-server      default         1               2024-09-23 19:27:27.694125 -0500 -05    deployed        nfs-server-provisioner-1.8.0    4.0.8
```

## List the Storage Classes in Kind

```shell
k get storageclass
NAME                 PROVISIONER                                               RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
nfs                  cluster.local/nfs-ganesha-server-nfs-server-provisioner   Delete          Immediate              true                   6m11s
standard (default)   rancher.io/local-path                                     Delete          WaitForFirstConsumer   false                  138m
```

## References

- [NFS Ganesha Server](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/blob/master/charts/nfs-server-provisioner/README.md)
- [NFS in Kind Cluster](https://cloudyuga.guru/blogs/nfs-kind/)