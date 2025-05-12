# Question 6 - Storage PV, PVC and Pod Volume - 8%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create a new `PersistentVolume` named `safari-pv`.
  - With `2Gi` of capacity.
  - Set `accessMode` to `ReadWriteOnce`.
  - Set `hostPath` to `/Volumes/Data`.
  - Don't define `storageClassName`.
- Create a new `PersistentVolumeClaim` in Namespace `project-tiger` named `safari-pvc`.
  - It should request `2Gi` storage.
  - Set `accessMode` to `ReadWriteOnce`.
  - Don't define `storageClassName`.
  - The PVC should be bound to the PV correctly.
- Create a new `Deployment` named `safari` in Namespace `project-tiger`.
  - Mount the volume at `/tmp/safari-data`.
  - The pods of that Deployment should be of image `httpd:2.4.41-alpine`.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the PersistentVolume

#### Get PersistentVolume Definition from Kubernetes Documentation

- Go to https://kubernetes.io/docs.
- Search for `PersistentVolume` yaml.
- Open the first link `Configure a Pod to Use a PersistentVolume for Storage`.
- Scroll down to `Create a PersistentVolume` and copy the YAML definition and update accordingly to the task.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/Volumes/Data"
```

#### Create the PersistentVolume YAML Definition

```shell
vim 06-pv.yaml
```

#### Apply the PersistentVolume YAML Definition

```shell
k apply -f 6-pv.yaml
persistentvolume/safari-pv created
```

### Create the PersistentVolumeClaim

#### Get PersistentVolumeClaim Definition from Kubernetes Documentation

- In the same document scroll down to `Create a PersistentVolumeClaim` and copy the YAML definition and update accordingly to the task.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-tiger
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

#### Create the PersistentVolumeClaim YAML Definition

```shell
vim 6-pvc.yaml
```

#### Apply the PersistentVolumeClaim YAML Definition

```shell
k apply -f 6-pvc.yaml
persistentvolumeclaim/safari-pvc created
```

#### List the PersistentVolumeClaim

```shell
k -n project-tiger get pvc,pv
NAME                               STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/safari-pvc   Pending                                      standard       <unset>                 2m1s

NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/safari-pv   2Gi        RWO            Retain           Available                          <unset>                          10m
```

### Create the Deployment

#### Get the VolumeDefinition

- In the same document scroll down to `Create a Pod` and create the volume definition accordingly to the task.

#### VolumeYaml Definition

```yaml
spec:
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: safari-pvc
  containers:
    - name: httpd
      image: httpd:2.4.41-alpine
      volumeMounts:
        - mountPath: /tmp/safari-data
          name: data
```

### Create the Deployment YAML Definition

```shell
k -n project-tiger create deploy safari --image=httpd:2.4.41-alpine -o yaml --dry-run=client > 6-deploy.yaml
```

And update the `volumes` and `volumeMounts` entries.

#### Apply the Deployment YAML Definition

```shell
k -n project-tiger apply -f 6-deploy.yaml
deployment.apps/safari created
```

#### Validate the Deployment

```shell
k -n project-tiger get deploy
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
safari   1/1     1            1           43s
```

#### Validate the PersistentVolume and PersistentVolumeClaim

```shell
k -n project-tiger get pv,pvc
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                      STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-5c6d3ef3-c5a1-4c60-b286-e9060a58e465   2Gi        RWO            Delete           Bound       project-tiger/safari-pvc   standard       <unset>                          3m15s
persistentvolume/safari-pv                                  2Gi        RWO            Retain           Available                                             <unset>                          25m

NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/safari-pvc   Bound    pvc-5c6d3ef3-c5a1-4c60-b286-e9060a58e465   2Gi        RWO            standard       <unset>                 17m
```

#### Validate the Deployment Pod Mount

```shell
k -n project-tiger describe pod safari-748b65955-drvdr | grep -A2 Mounts:
    Mounts:
      /tmp/safari-data from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-l7xb2 (ro)
```
</details>
