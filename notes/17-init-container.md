# Init Container

## Create the init-container

```shell
kubectl run init --image=busybox:1.35 --command "sh" "c" "echo The app is running! && sleep 3600" --dry-run=client -o yaml > yaml-definitions/init-container.yaml
```

### Change the c to -c

Open the file `yaml-definitions/init-container.yaml` and change the `c` to `-c`.

## Create the initContainers

- Enter `initContainers:` inline with the word `containers`
- Create the same configuration of the main container, the only thing that change is the command.

```shell
containers:
initContainers:
- name: init-svc
  image: busybox:1.35
  command:
  - sh 
  - -c
  - until nslookup init-svc; do echo waiting for svc; sleep 2; done
```

## Apply the yaml-definitions/init-container.yaml

```shell
kubectl apply -f yaml-definitions/init-container.yaml
```

### Validate the pod creation

```shell
watch kubectl get pod

Every 2.0s: kubectl get po                                                                                                                  192.168.1.12: Tue Aug 27 22:15:16 2024

NAME   READY   STATUS     RESTARTS   AGE
init   0/1     Init:0/1   0          56s
```

### Create the init-svc

```shell
kubectl create svc clusterip init-svc --tcp 80

service/init-svc created
```

## Delete the init Pod

```shell
kubectl delete pod init
```

## Delete the service

```shell
kubectl delete svc init-svc
```
