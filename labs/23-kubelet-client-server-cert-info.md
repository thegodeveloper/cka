# Question 23 - Kubelet client/server cert info - 2%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Node `k8s-c2-worker` has been added to the cluster using `kubeadm` and `TLS bootstrapping`.
- Find the `Issuer` and `Extended Key Usage` values of the `k8s-c2-worker`.
  - kubelet `client` certificate, the one used for outgoing connections to the `kube-apiserver`.
  - kubelet `server` certificate, the one used for incoming connections form the `kube-apiserver`.
- Write the information into file `23-certificate-info.txt`.
- Compare the `Issuer` and `Extended Key Usage` fields of both certificates and make sense of these.

## Solution

<details>
  <summary>Show the solution</summary>

### Find the correct kubelet certificate directory

```shell
docker exec -it k8s-c2-worker bash
root@k8s-c2-worker:/# ls /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

```
root@k8s-c2-worker:/# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 
# https://github.com/kubernetes/kubernetes/blob/ba8fcafaf8c502a454acd86b728c857932555315/build/debs/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

Look at the `EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env` and go the directory where this file is located.

```shell
root@k8s-c2-worker:/# cd /var/lib/kubelet
root@k8s-c2-worker:/var/lib/kubelet# ls -l
total 40
-rw-r--r-- 1 root root 1178 Nov 13 02:25 config.yaml
-rw------- 1 root root   62 Nov 13 02:25 cpu_manager_state
drwxr-xr-x 2 root root 4096 Nov 13 02:25 device-plugins
-rw-r--r-- 1 root root  230 Nov 13 02:25 kubeadm-flags.env
-rw------- 1 root root   61 Nov 13 02:25 memory_manager_state
drwxr-xr-x 2 root root 4096 Nov 13 02:25 pki
drwxr-x--- 2 root root 4096 Nov 13 02:25 plugins
drwxr-x--- 2 root root 4096 Nov 13 02:25 plugins_registry
drwxr-x--- 2 root root 4096 Nov 13 02:25 pod-resources
drwxr-x--- 4 root root 4096 Nov 13 02:25 pods
root@k8s-c2-worker:/var/lib/kubelet# cd pki
root@k8s-c2-worker:/var/lib/kubelet/pki# ls
kubelet-client-2024-11-13-02-25-31.pem	kubelet-client-current.pem  kubelet.crt  kubelet.key
```

### Validate the issuer of the certificate of the client

```shell
root@k8s-c2-worker:/var/lib/kubelet/pki# openssl x509 -noout -text -in kubelet-client-current.pem | grep Issuer
        Issuer: CN = kubernetes
```

```shell
root@k8s-c2-worker:/var/lib/kubelet/pki# openssl x509 -noout -text -in kubelet-client-current.pem | grep "Extended Key Usage" -A1
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
```

### Validate the issuer of the certificate of the server


```shell
root@k8s-c2-worker:/var/lib/kubelet/pki# openssl x509 -noout -text -in kubelet.crt | grep Issuer
        Issuer: CN = k8s-c2-worker-ca@1731464731
```

```shell
root@k8s-c2-worker:/var/lib/kubelet/pki# openssl x509 -noout -text -in kubelet.crt | grep "Extended Key Usage" -A1
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
```


### Write the information to certificate info file

```shell
vim 23-certificate-info.txt
```

Add the following information:

```shell
Client Issuer:
Issuer: CN = kubernetes

Client Extended Key Usage:
X509v3 Extended Key Usage: 
  TLS Web Client Authentication

Server Issuer:
Issuer: CN = k8s-c2-worker-ca@1731464731

Server Extended Key Usage:
X509v3 Extended Key Usage: 
  TLS Web Server Authentication
```

</details>
