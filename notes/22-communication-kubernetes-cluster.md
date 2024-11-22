# Communication in Kubernetes Cluster

## Configuring DNS

- Change the IP address associated with the cluster DNS Service to match a new Service range of 100.96.0.0/96.
- Change the `kubelet` configuration so that new Pods can receive the new DNS Service IP address and can resolve domain names.
- Edit the `kubelet ConfigMap` so that kubelet is updated in place and immediately reflected.
- Upgrade the node to receive the new kubelet configuration.
- Test it by creating a new Pod and verifying that has the new IP address of the DNS Service.

### Get Cluster Nodes

```shell
kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
cka-control-plane   Ready    control-plane   12m   v1.29.0
cka-worker          Ready    <none>          12m   v1.29.0
cka-worker2         Ready    <none>          12m   v1.29.0
```

### Access the Control Plane

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/#
```

### Change Service CIDR Block

```shell
# This is a feature that is controlled by the API server.
cd /etc/kubernetes/manifests/
ls -l kube-apiserver.yaml
-rw------- 1 root root 3896 Sep  3 12:09 kube-apiserver.yaml

# Edit the file using vim
vim kube-apiserver.yaml
bash: vim: command not found

# Install VIM
apt update
apt install vim
Do you want to continue? [Y/n] y (Enter y)

# Edit the file using vim
vim kube-apiserver.yaml

# Search for `service-cluster-ip-range`
# In vim use: shift + / then search the pattern
- --service-cluster-ip-range=10.96.0.0/16
# Change for:
- --service-cluster-ip-range=100.96.0.0/16
# Save and close the file
```

- After change the CIDR block range, wait for 2 minutes for the API server to reboot.

### Change the IP address associated with the cluster DNS Service

#### Validate the current state of the DNS Service

```shell
kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   26m
```

- The `DNS Service` is using the all IP address (10.96.0.10), should start with 100.

#### Edit the DNS Service

```shell
kubectl edit svc kube-dns -n kube-system
# change the IP address 10.96.0.10 to 100.96.0.10 in
# clusterIP: 10.96.0.10
# - 10.96.0.10
```

- You will receive the message: `# Please edit the object below. Lines beginning with a '#' will be ignored,nge once set`
- Save the file again using `:wq`
- You will get a message that says the following:

```shell
error: services "kube-dns" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-4162470953.yaml"
error: Edit cancelled, no valid changes were saved.
```

#### Replace the service with force

```shell
kubectl replace -f /tmp/kubectl-edit-4162470953.yaml --force
service "kube-dns" deleted
service/kube-dns replaced
```

#### Validate the Service DNS

```shell
kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   100.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   61s
```

- The IP address change to `100.96.0.10`

### Change kubelet configuration

#### Change the config.yaml file

```shell
vim /var/lib/kubelet/config.yaml
# change
clusterDNS:
- 10.96.0.10
# to
clusterDNS:
- 100.96.0.10
# save the file
```

#### Change the ConfigMap associated with kubelet configuration

```shell
kubectl edit cm kubelet-config -n kube-system
# change
clusterDNS:
- 10.96.0.10
# to
clusterDNS:
- 100.96.0.10
# save the configmap
configmap/kubelet-config edited
```

#### Update the nodes

##### Update the kubelet configuration on the node

```shell
kubeadm upgrade node phase kubelet-config

[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
W0903 12:57:13.022329    3055 utils.go:69] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.96.0.10]; the provided value is: [100.96.0.10]
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config3086822048/config.yaml
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
```

##### Reload the daemon

```shell
systemctl daemon-reload
systemctl restart kubelet
```

### Validate the cluster

```shell
kubectl run netshoot --image=nicolaka/netshoot --command sleep --command "3600"
pod/netshoot created
```

```shell
kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
netshoot   1/1     Running   0          52s
```

```shell
kubectl exec -it netshoot -- bash

netshoot:~# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 100.96.0.10
options ndots:5

netshoot:~# nslookup example.com
Server:         100.96.0.10
Address:        100.96.0.10#53

Non-authoritative answer:
Name:   example.com
Address: 93.184.215.14
Name:   example.com
Address: 2606:2800:21f:cb07:6820:80da:af6b:8b2c
```
