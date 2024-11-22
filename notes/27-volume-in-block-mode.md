# Volume in Block Mode

## Create a PV in Block Mode

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vol007
  labels:
    type: local
spec:
  storageClassName: manual
  volumeMode: Block
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

## Apply PV in Block Mode

```shell
k apply -f yaml-definitions/pv-block-mode.yaml
persistentvolume/vol007 created
```

## List the PVs

```shell
k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-64549fb9-6d89-4271-9b21-cf150b4d2dc3   1Mi        RWX            Delete           Bound       default/nfs-claim     nfs            <unset>                          13m
vol007                                     100Mi      RWO            Retain           Available                         manual         <unset>                          24s
vol02883                                   100Mi      RWO            Retain           Bound       default/claim-02833   manual         <unset>                          155m
```