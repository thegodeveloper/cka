# To Remember

## Static Pods Location

```shell
cd /etc/kubernetes/manifests/

docker exec -it cka-control-plane bash
root@cka-control-plane:/# cd /etc/kubernetes/manifests/
root@cka-control-plane:/etc/kubernetes/manifests# ls -l
total 16
-rw------- 1 root root 2404 Sep  3 12:09 etcd.yaml
-rw------- 1 root root 3897 Sep  3 12:33 kube-apiserver.yaml
-rw------- 1 root root 3427 Sep  3 12:09 kube-controller-manager.yaml
-rw------- 1 root root 1463 Sep  3 12:09 kube-scheduler.yaml
```

## Control Plane Container

Remember that the manifests for control plane components are in the `/etc/kubernetes/manifests/` directory. This directory will be located on the control plane server, which you will have to SSH into to view or modify.

```shell
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

## Validate Command Syntax

- To validate what values go where in YAML file during the exam, you can use `kubectl explain`.
- The command `kubectl explain deploy.spec.strategy` will list values that are available for input in the spec field.

## Commands to restart the kubelet

```shell
systemctl stop kubelet
systemctl restart kubelet
systemctl daemon-reload
```

## Create a tool to run commands using Alpine

```shell
k run tool --image alpine -it --rm -- sh
If you don't see a command prompt, try pressing enter.
/ #
```

### Install curl

```shell
/ # apk add --no-cache curl
```

## Create busybox image

### Creating a YAML Definition

```shell
k run log-collector --image busybox --command sleep --command "3600" --dry-run=client -o yaml > yaml-definitions/log-collector.yaml
```

Remove from the file:

- creationTimestamp: null
- status: {}

## Copy and Paste in Vim

Being able to `copy` and `paste` in `Vim` can save time on the exam. Select lines by pressing `Shift + V` on your keyboard, followed by the `up` and `down` arrows to select. Once you've selected all the lines, press the `Y` key to copy and the `P` key to paste.

## Create a Pod from Nginx Exam

```shell
k run nginx --image=nginx --port=80 -o yaml --dry-run=client > nginx.yaml
```

