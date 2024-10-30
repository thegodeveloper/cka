# Storage in Kubernetes

## Persistent Volumes

- `Persistent Volumes` are not namespaced
- A `Persistent Volume (PV)` that is mounted to a Pod, which can act as an independent entity
- The `emptyDir` volume
- The `hostPath` volume
- The `NFS` volume

## Access Modes

- `ReadWriteOnce` only one node can mount the volume, read and write to it
- `ReadOnlyMany` multiple nodes can mount the volume for reading only
- `ReadWriteMany` multiple nodes can mount the volume for reading and writing
- `ReadWriteOncePod` only one node can mount the volume for reading and writing
- A `Persistent Volume` can have more than one access mode
- A `Persistent Volume Claim` can only have one access mode
- Even if there are many modes specified in the PV YAML, the node can only utilize once access mode at a time

## Important

- Certain volumes only support certain access modes
- `hostPath` is not able to support `ReadOnlyMany`, `ReadWriteMany`, or `ReadWriteOncePod`

## Create a cluster

Follow the instructions in [00 - Create Cluster](00-create-cluster.md)

## Get the PV Yaml definition from Kubernetes Doc

- Go to https://kubernetes.io/docs and use the search bar on the left of the screen to search for the phrase `use a persistent volume`
- Click on the link that says `Configure a Pod to Use a PersistentVolume for Storage`
- Scroll down to the section `Create a Persistent Volume`
- Copy and paste the YAML from this page into a new file named `yaml-definitions/pv.yaml`

## Persistent Volume YAML Definition

- Change the PV name from `task-pv-volume` to `vol02883`
- Change the storage from `10Gi` to `100Mi`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vol02883
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

## Deploy the Persistent Volume

```shell
k apply -f yaml-definitions/pv.yaml
persistentvolume/vol02883 created
```

## Validate the PV

- The status is `Available`, which means it's ready to be claimed

```shell
k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
vol02883   100Mi      RWO            Retain           Available           manual         <unset>                          31s
```

## Copy the Persistent Volume Claim from the documentation

- Scroll down on the same page in the Kubernetes documentation to `Create a PersistentVolumeClaim`
- Change the name of the PVC from `task-pv-claim` to `claim-02833`
- Change the storage from `3Gi` to `90Mi`
- Copy and paste the YAML from this page into a new file named `yaml-definitions/pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-02833
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 90Mi
```

## Create the Persistent Volume Claim

```shell
k apply -f yaml-definitions/pvc.yaml
persistentvolumeclaim/claim-02833 created
```

## Validate the PVC

- Even though we specified 90Mi in the PVC YAML, the capacity is 100Mi
- This is because the PVC will try to find the closest fit to the nearest PV that can fulfill that claim bu cannot reserve only a portion of the PV
- If we had requested 200Mi, the PVC would not be satisfied, as there is no matching PV with the requested amount of storage

```shell
k get pvc
NAME          STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
claim-02833   Bound    vol02883   100Mi      RWO            manual         <unset>                 34s
```

## Create a Deployment

### Create the deployment YAML definition

```shell
k create deploy frontend0113 --image nginx --dry-run=client -o yaml > yaml-definitions/pvc-deployment.yaml
```

Remove from the `yaml-definitions/pvc-deployment.yaml` file the following entries:

- creationTimestamp: null (twice)
- status: {}

### Adding the volumes syntax to a Deployment spec

Add the following `volume` definition in line with `containers:`

```yaml
containers:
volumes:
- name: vol-33
  persistentVolumeClaim:
    claimName: claim-02833
```

### Adding the volumeMounts to the container in the Deployment

```yaml
containers:
- image: nginx
  name: nginx
  resources: {}
  volumeMounts:
  - name: vol-33
    mountPath: "/usr/share/nginx/html"
```

### Create the Deployment

```shell
k apply -f yaml-definitions/pvc-deployment.yaml
deployment.apps/frontend0113 created
```

### Validate the Deployment

```shell
k get deploy
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
frontend0113   1/1     1            1           33s
```

### Validate the Pods

```shell
k get pod
NAME                           READY   STATUS    RESTARTS   AGE
frontend0113-d79c45fd4-qqwm9   1/1     Running   0          70s
```

### Describe the Pod

```shell
k describe pod frontend0113-d79c45fd4-qqwm9
Volumes:
  vol-33:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  claim-02833
    ReadOnly:   false
```