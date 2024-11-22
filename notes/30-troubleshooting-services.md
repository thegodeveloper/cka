# Troubleshooting Services

## Create a namespace kb6656

```shell
k create ns kb6656
namespace/kb6656 created
```

## Switch context to namespace kb6656

```shell
k config set-context --current --namespace kb6656
Context "kind-cka" modified.
```

## Apply the command given during the exam

```shell
k apply -f yaml-definitions/deploy-and-svc.yaml
deployment.apps/nginx created
service/nginx-svc created
```

## List the Deployment and Service

```shell
k get deploy,svc
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           48s

NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/nginx-svc   ClusterIP   10.96.216.230   <none>        3306/TCP   48s
```

## Connect to the control-plane

```shell
docker exec -it cka-control-plane bash
root@cka-control-plane:/#
```

### Reach out the application using curl and the cluster IP

```shell
root@cka-control-plane:/# curl -k http://10.96.216.230
curl: (7) Failed to connect to 10.96.216.230 port 80: Connection refused
```

We are unable to reach the service, because the service is pointing to port `3306` not to port `80`.

### Edit the service and change to port 80

```shell
k edit svc nginx-svc
service/nginx-svc edited
```

Change:

```yaml
- port: 80
  protocol: TCP
  targetPort: 80
```

### List the service

```shell
k get svc
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx-svc   ClusterIP   10.96.216.230   <none>        80/TCP    8m42s
```

### Curl to the service again

```shell
root@cka-control-plane:/# curl -k http://10.96.216.230
```

  

