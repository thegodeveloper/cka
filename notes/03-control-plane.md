# The Control Plane

The `Control Plane` runs an initial set of Pods, comprised of control plane components. We refer to them as `system Pods` because they contain the necessary structure around the running of the entire `Kubernetes` system.

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- etcd

## Check the system Pods

```shell
kubectl get po -o wide -A --field-selector spec.nodeName=cka-control-plane

NAMESPACE     NAME                                        READY   STATUS    RESTARTS      AGE   IP           NODE                NOMINATED NODE   READINESS GATES
kube-system   coredns-76f75df574-btzzt                    1/1     Running   0             21m   10.244.0.5   cka-control-plane   <none>           <none>
kube-system   etcd-cka-control-plane                      1/1     Running   0             41m   172.18.0.3   cka-control-plane   <none>           <none>
kube-system   kindnet-s7bbm                               1/1     Running   2 (40m ago)   63m   172.18.0.3   cka-control-plane   <none>           <none>
kube-system   kube-apiserver-cka-control-plane            1/1     Running   0             40m   172.18.0.3   cka-control-plane   <none>           <none>
kube-system   kube-controller-manager-cka-control-plane   1/1     Running   0             40m   172.18.0.3   cka-control-plane   <none>           <none>
kube-system   kube-proxy-xzq7k                            1/1     Running   0             39m   172.18.0.3   cka-control-plane   <none>           <none>
kube-system   kube-scheduler-cka-control-plane            1/1     Running   0             40m   172.18.0.3   cka-control-plane   <none>           <none>
```

`CoreDNS` is also a Pod that runs on the control plane node, but it's considered a plugin, not a core system Pod.