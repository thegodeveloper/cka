# Multicontainer Pods

## Create sidecar YAML definition

```shell
kubectl run sidecar --image=busybox --command "sh" "c" "while true; do cat /var/log/nginx/error.log; sleep 20; done" --dry-run=client -o yaml > yaml-definitions/sidecar.yaml
```

### Change the c to -c

Open the file `yaml-definitions/sidecar.yaml` and change the `c` to `-c`.

### Add volumeMounts to the sidecar

```shell
resources: {}
volumeMounts:
  - name: log-vol
    mountPath: /var/log/nginx
```

### Add another image (at the same level of command:)

```shell
- name: nginx
  image: nginx
  volumeMounts:
    - name: log-vol
      mountPath: /var/log/nginx
```

### Add volumes section (at the same level of containers:)

- An `emptyDir` volume is one of many types of volumes that live and die with the container.
- This is ephemeral storage, so as soon as the Pod is deleted, the data is also deleted and gone forever.

```shell
containers:
volumes: 
  - name: log-vol
    emptyDir: {}
```

## Create the sidecar

```shell
kubectl apply -f yaml-definitions/sidecar.yaml
```

### Validate the sidecar

```shell
kubectl get pod

NAME      READY   STATUS    RESTARTS   AGE
sidecar   2/2     Running   0          18s
```

### Delete the sidecar

```shell
kubectl delete pod sidecar
pod "sidecar" deleted
```