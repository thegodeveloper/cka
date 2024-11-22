# HostPath Implementation with NFS

## Persistent Volume Claim Definition

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nfs
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```

## Create the Persistent Volume Claim

```shell
k apply -f yaml-definitions/nfs-pvc.yaml
persistentvolumeclaim/nfs-claim created
```

## List Persistent Volume Claim

```shell
k get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
claim-02833   Bound    vol02883                                   100Mi      RWO            manual         <unset>                 135m
nfs-claim     Bound    pvc-64549fb9-6d89-4271-9b21-cf150b4d2dc3   1Mi        RWX            nfs            <unset>                 24s
```

## List Persistent Volume

```shell
k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-64549fb9-6d89-4271-9b21-cf150b4d2dc3   1Mi        RWX            Delete           Bound    default/nfs-claim     nfs            <unset>                          41s
vol02883                                   100Mi      RWO            Retain           Bound    default/claim-02833   manual         <unset>                          143m
```

## Create the NFS Deployment

```shell
k apply -f yaml-definitions/nfs-deployment.yaml
deployment.apps/rsvp-db1 created
```

## List the Deployment

```shell
k get deploy
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
frontend0113   1/1     1            1           123m
rsvp-db1       1/2     2            1           2m21s
```

## ToDo

- Fix the deployment