# Client & Server Certificates

List the contents of `/etc/kubernetes` directory.

```shell
root@cka-control-plane:/# ls -l /etc/kubernetes
total 44
-rw------- 1 root root 5633 Jul 19 22:03 admin.conf
-rw------- 1 root root 5646 Jul 19 22:03 controller-manager.conf
-rw------- 1 root root 1989 Jul 19 22:03 kubelet.conf
drwxr-xr-x 1 root root 4096 Jul 19 23:55 manifests
drwxr-xr-x 3 root root 4096 Jul 19 22:03 pki
-rw------- 1 root root 5598 Jul 19 22:03 scheduler.conf
-rw------- 1 root root 5657 Jul 19 22:03 super-admin.conf
```

You'll see the following files which are representative of the `kubeconfig` used to authenticate to the Kubernetes API:

- controller-manager.conf
- kubelet.conf
- scheduler.conf

If we view the contents of `kubelet.conf` file, we'll see a config similar to our kubectl kubeconfig. Type the command `cat /etc/kubernetes/kubelet.conf`:

```shell
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: EDITED
    server: https://cka-control-plane:6443
  name: cka
contexts:
- context:
    cluster: cka
    user: system:node:cka-control-plane
  name: system:node:cka-control-plane@cka
current-context: system:node:cka-control-plane@cka
kind: Config
preferences: {}
users:
- name: system:node:cka-control-plane
  user:
    client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
    client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
```
