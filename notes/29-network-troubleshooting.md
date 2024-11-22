# Network Troubleshooting

## Create a cluster

```shell
kind create cluster --name cka --config yaml-definitions/cluster.yaml
```

## Insert a bug in the cluster

```shell
k replace -f yaml-definitions/kube-proxy-configmap.yaml --force
configmap "kube-proxy" deleted
configmap/kube-proxy replaced
```

## List the kube-proxy pods in the kube-system namespace

```shell
k get pods -n kube-system -l k8s-app=kube-proxy
NAME               READY   STATUS    RESTARTS   AGE
kube-proxy-cpdfl   1/1     Running   0          2m21s
kube-proxy-g9qsr   1/1     Running   0          2m16s
kube-proxy-nmzz5   1/1     Running   0          2m17s
```

## Delete 1 kube-proxy pod from the list

```shell
k delete pod kube-proxy-cpdfl -n kube-system
pod "kube-proxy-cpdfl" deleted
```

## List the kube-proxy pods again

One of the kube-proxy pod should be in `CrashLoopBackOff` state.

```shell
k get pods -n kube-system -l k8s-app=kube-proxy
NAME               READY   STATUS             RESTARTS      AGE
kube-proxy-b5rk6   0/1     CrashLoopBackOff   2 (22s ago)   35s
kube-proxy-g9qsr   1/1     Running            0             4m6s
kube-proxy-nmzz5   1/1     Running            0             4m7s
```

## Check the problematic kube-proxy pod logs

```shell
k -n kube-system logs kube-proxy-b5rk6
I1023 02:57:42.437946       1 server.go:509] "Using lenient decoding as strict decoding failed" err="strict decoding error: unknown field \"udpIdleTimeout\""
I1023 02:57:42.438004       1 server_others.go:72] "Using iptables proxy"
E1023 02:57:42.438216       1 server.go:556] "Error running ProxyServer" err="stat /var/lib/kube-proxy/kubeconfigd.conf: no such file or directory"
E1023 02:57:42.438227       1 run.go:74] "command failed" err="stat /var/lib/kube-proxy/kubeconfigd.conf: no such file or directory"
```

- The error says `/var/lib/kube-proxy/kubeconfigd.conf` file does not exist.
- We also know that this configuration comes from a config map.

## List the config maps in kube-system namespace

`Tip` for the exam: Enter `k -n kube-system get cm kube` and press tab. 

```shell
k -n kube-system get cm kube
kube-apiserver-legacy-service-account-token-tracking  kube-root-ca.crt                                      kubelet-config
kube-proxy                                            kubeadm-config
```

As you can see there is a `kube-proxy` configmap in the list.

## Edit the kube-proxy configmap

```shell
k -n kube-system edit cm kube-proxy
configmap/kube-proxy edited
```

Search for `kubeconfigd.conf` using vim.

```shell
ESC + Shift + / + kubeconfigd
```

Remove the `d` from `kubeconfigd.conf` and save configmap.

## List the kube-proxy pods

You should see that nothing happens after editing the configmap.

```shell
k get pods -n kube-system -l k8s-app=kube-proxy
NAME               READY   STATUS             RESTARTS        AGE
kube-proxy-b5rk6   0/1     CrashLoopBackOff   8 (3m32s ago)   19m
kube-proxy-g9qsr   1/1     Running            0               22m
kube-proxy-nmzz5   1/1     Running            0               22m
```

## Delete the kube-proxy pod in CrashLoopBackOff state

```shell
k -n kube-system delete pod kube-proxy-b5rk6
pod "kube-proxy-b5rk6" deleted
```

## List the kube-proxy pods again

You should see the `kube-proxy` pods in healthy state again.

```shell
k get pods -n kube-system -l k8s-app=kube-proxy
NAME               READY   STATUS    RESTARTS   AGE
kube-proxy-g9qsr   1/1     Running   0          24m
kube-proxy-nmzz5   1/1     Running   0          24m
kube-proxy-trm87   1/1     Running   0          30s
```