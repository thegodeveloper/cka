# Question 22 - Check how long certificates are valid - 2%

## Use context

```shell
kubectl config use-context kind-k8s-c2
```

## Task Definition

- Check how long the `kube-apiserver` server certificate is valid on `k8s-c2-control-plane`. Do this with `openssl` or `cfssl`.
- Write the expiration date into `22-expiration.txt`.
- Also run the correct `kubeadm` command to list the expiration dates and confirm both methods show the same date.
- Write the correct `kubeadm` command that would renew the `apiserver` server certificate to `22-kubeadm-renew-certs.sh`.

## Solution

<details>
  <summary>Show the solution</summary>

### Find the certificate in the k8s-c2-control-plane

```shell
docker exec -it k8s-c2-control-plane
root@k8s-c2-control-plane:/# cd /etc/kubernetes/pki/
root@k8s-c2-control-plane:/etc/kubernetes/pki# ls -la
total 72
drwxr-xr-x 3 root root 4096 Nov 13 02:25 .
drwxr-xr-x 1 root root 4096 Nov 13 02:25 ..
-rw-r--r-- 1 root root 1123 Nov 13 02:25 apiserver-etcd-client.crt
-rw------- 1 root root 1675 Nov 13 02:25 apiserver-etcd-client.key
-rw-r--r-- 1 root root 1176 Nov 13 02:25 apiserver-kubelet-client.crt
-rw------- 1 root root 1679 Nov 13 02:25 apiserver-kubelet-client.key
-rw-r--r-- 1 root root 1326 Nov 13 02:25 apiserver.crt
-rw------- 1 root root 1675 Nov 13 02:25 apiserver.key
-rw-r--r-- 1 root root 1107 Nov 13 02:25 ca.crt
-rw------- 1 root root 1675 Nov 13 02:25 ca.key
drwxr-xr-x 2 root root 4096 Nov 13 02:25 etcd
-rw-r--r-- 1 root root 1123 Nov 13 02:25 front-proxy-ca.crt
-rw------- 1 root root 1675 Nov 13 02:25 front-proxy-ca.key
-rw-r--r-- 1 root root 1119 Nov 13 02:25 front-proxy-client.crt
-rw------- 1 root root 1675 Nov 13 02:25 front-proxy-client.key
-rw------- 1 root root 1679 Nov 13 02:25 sa.key
-rw------- 1 root root  451 Nov 13 02:25 sa.pub

root@k8s-c2-control-plane:/etc/kubernetes/pki# openssl x509 -noout -text -in ./apiserver.crt | grep Validity -A2 
        Validity
            Not Before: Nov 13 02:20:03 2024 GMT
            Not After : Nov 13 02:25:03 2025 GMT

exit
```

```shell
echo 'Nov 13 02:25:03 2025 GMT' > 22-expiration.txt
```

### Check the expiration date using kubeadm in k8s-c2-control-plane

```shell
docker exec -it k8s-c2-control-plane bash
root@k8s-c2-control-plane:~# kubeadm certs check-expiration | grep apiserver
apiserver                  Nov 13, 2025 02:25 UTC   364d            ca                      no      
apiserver-etcd-client      Nov 13, 2025 02:25 UTC   364d            etcd-ca                 no      
apiserver-kubelet-client   Nov 13, 2025 02:25 UTC   364d            ca                      no
```

### Write the kubeadm command to renew the apiserver cert

```shell
echo 'kubeadm certs renew apiserver' > 22-kubeadm-renew-certs.sh
```

</details>
