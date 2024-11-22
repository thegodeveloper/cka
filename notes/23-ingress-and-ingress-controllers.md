# Ingress & Ingress Controllers

- To perform application layer (layer-7) routing to your application in Kubernetes, the term that's used is `Ingress`.
- The reason it's a preferred method is that Ingress provides a single gateway (only one entry) into the cluster and can route traffic to multiple `Services` using simple path-based routes.
- Along with an `Ingress Controller`, you can set these routes in the `Ingress` resource, and it will be directed to each `Service`.

## Create a Kind Cluster

```shell
kind create cluster --name cka --config yaml-definitions/cluster2.yaml
```

## Connect to Control Plane Node

```shell
docker exec -it cka-control-plane bash
```

## Configure the k alias

```shell
alias k=kubectl
```

## Validate the control plane labels

```shell
k get node --show-labels
NAME                STATUS   ROLES           AGE    VERSION   LABELS
cka-control-plane   Ready    control-plane   4m6s   v1.29.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,ingress-ready=true,kubernetes.io/arch=arm64,kubernetes.io/hostname=cka-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=
```

## Validate the port in the node is exposed

```shell
docker port cka-control-plane
80/tcp -> 0.0.0.0:80
6443/tcp -> 127.0.0.1:49671
```

## Install Ingress Controller

```shell
k apply -f https://raw.githubusercontent.com/chadmcrowell/acing-the-cka-exam/main/ch_06/nginx-ingress-controller.yaml

namespace/ingress-nginx created
serviceaccount/ingress-nginx created
serviceaccount/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
configmap/ingress-nginx-controller created
service/ingress-nginx-controller created
service/ingress-nginx-controller-admission created
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
```

## Validate the Resources

```shell
k get all -n ingress-nginx

NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-lckrh        0/1     Completed   0          40s
pod/ingress-nginx-admission-patch-kls4d         0/1     Completed   2          40s
pod/ingress-nginx-controller-54877c6476-5ktr5   1/1     Running     0          40s

NAME                                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             NodePort    10.96.75.167   <none>        80:32205/TCP,443:32034/TCP   40s
service/ingress-nginx-controller-admission   ClusterIP   10.96.37.139   <none>        443/TCP                      40s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           40s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-54877c6476   1         1         1       40s

NAME                                       COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   1/1           10s        40s
job.batch/ingress-nginx-admission-patch    1/1           23s        40s
```

## Create a Deployment

```shell
k create deploy hello --image=nginxdemos/hello:plain-text --port=80
deployment.apps/hello created
```

## Create a Service for the Deployment

```shell
k expose deploy hello --name hello-svc --port 80
service/hello-svc exposed
```

## Validate the Resources

```shell
kubectl get svc,deploy

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/hello-svc    ClusterIP   10.96.76.212   <none>        80/TCP    52s
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   5m38s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello   1/1     1            1           112s
```

## Create an Ingress Resource

Run this outside of the control plane node.

```shell
kubectl apply -f yaml-definitions/hello-ingress.yaml
ingress.networking.k8s.io/hello created
```

## Validate the Ingress

```shell
kubectl get ingress

NAME    CLASS    HOSTS       ADDRESS     PORTS   AGE
hello   <none>   hello.com   localhost   80      44s
```

## Install vim

```shell
apt update && apt install -y vim
```

## Get the IP address of the Control Plane Node

```shell
k get nodes -o wide                                                                                                                                                          ─╯
NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
cka-control-plane   Ready    control-plane   23s   v1.29.0   172.18.0.2    <none>        Debian GNU/Linux 11 (bullseye)   6.10.4-linuxkit   containerd://1.7.1
```

## Add an entry to /etc/hosts file

```shell
vim /etc/hosts
```

Add to the end of the file the following:

172.18.0.2 hello.com

## Get the ingress

```shell
curl hello.com
Server address: 10.244.0.8:80
Server name: hello-66c648c697-hs2wh
Date: 20/Sep/2024:03:35:12 +0000
URI: /
Request ID: 84b1e81078cfd82ff76037316dc15baa
```

## Get the pod IP Address

```shell
k get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP           NODE                NOMINATED NODE   READINESS GATES
hello-66c648c697-hs2wh   1/1     Running   0          3m38s   10.244.0.8   cka-control-plane   <none>           <none>
```

Validate that the pod address is the same in the curl output.

## Add other rule to the ingress configuration

```shell
k edit ingress hello
```

And add the following configuration:

```yaml
- backend:
    service:
      name: nginx-svc
      port: 
        number: 8080
  path: /app
  pathType: Exact
```

## Create the Nginx Deployment

```shell
k create deploy nginx --image=nginx --port=80
deployment.apps/nginx created
```

## Create the Nginx Service

```shell
k expose deploy nginx --name nginx-svc --port 8080
service/nginx-svc exposed
```

