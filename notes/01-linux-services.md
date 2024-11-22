# Linux Services

## Get Cluster Nodes

````shell
k get nodes
NAME                STATUS   ROLES           AGE     VERSION
cka-control-plane   Ready    control-plane   6m17s   v1.29.0
cka-worker          Ready    <none>          5m55s   v1.29.0
cka-worker2         Ready    <none>          5m59s   v1.29.0
````

## Connect to Docker Container

```shell
docker exec -it cka-control-plane bash 
root@cka-control-plane:/#
```

## List services in Linux

To see a list of all services on your Linux system, type the following command:

```shell
sudo systemctl list-unit-files --type service --all | grep kubelet -a6
```

### Starting the kubelet service

```shell
systemctl start kubelet
```

### Enabling the kubelet service

```shell
systemctl enable kubelet
```

### Validate the kubelet service status

```shell
systemctl status kubelet
```

## Journald Service

### List the journald service

`Journald` (another Linux system service) is used to collect logs about the `kubelet` service on each node. `Journalctl` is a commandline utility for viewing logs on a Linux system collected by systemd, which is the primary daemon in Linux that controls all processes.

```shell
sudo systemctl list-unit-files --type service --all | grep journald.service
```

### Commands to check the kubelet logs with journalctl

```shell
sudo journalctl -u kubelet

sudo journalctl -u containerd
```

### Checking logs using journalctl

```shell
sudo journalctl -u kubelet

sudo journalctl -u containerd
```

