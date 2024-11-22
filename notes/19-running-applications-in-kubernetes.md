# Running Applications in Kubernetes

## Modifying Running Applications

### Create a Deployment

```shell
kubectl create deployment apache --image=httpd:2.4.54 --replicas=3
deployment.apps/apache created
```

### Validate the Deployment

```shell
kubectl get deploy apache
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
apache   3/3     3            3           30s
```

### Scale the Deployment

```shell
kubectl scale deploy apache --replicas=5
deployment.apps/apache scaled
```

### Validate the Deployment Scale

```shell
kubectl get deploy apache
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
apache   5/5     5            5           2m14s
```

### Change the Deployment Image

- Change the deployment image from `httpd:2.4.54` to `httpd:alpine`
- When the `Deployment` image is changed, a new `ReplicaSet` is created with a new set of `Pod` replicas.

```shell
kubectl set image deploy apache httpd=httpd:alpine
deployment.apps/apache image updated
```

## Application Maintenance

### Get the ReplicaSets

```shell
kubectl get rs
NAME                DESIRED   CURRENT   READY   AGE
apache-7bd5768c74   0         0         0       20m
apache-869b864c6b   5         5         5       15m
```

### Create a Deployment Definition

```shell
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > yaml-definitions/deployment.yaml
```

### Apply the Deployment Definition

```shell
kubectl apply -f yaml-definitions/deployment.yaml
deployment.apps/nginx created
```

### Validate the Deployment

```shell
kubectl get deploy nginx
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   3/3     3            3           32s
```

### Validate the Deployment ReplicaSet

```shell
kubectl get replicaset
NAME                DESIRED   CURRENT   READY   AGE
apache-7bd5768c74   0         0         0       27m
apache-869b864c6b   5         5         5       22m
nginx-7854ff8877    3         3         3       84s
```

### Scale the Deployment Modifying the YAML Definition

- Set the number of replicas to 7 in the YAML definition `yaml-definitions/deployment.yaml`

#### Apply the Deployment YAML Definition to Scale the Deployment

```shell
kubectl apply -f yaml-definitions/deployment.yaml
deployment.apps/nginx configured
```

#### Validate the number of pods in the deployment

```shell
kubectl get deploy nginx
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   7/7     7            7           5m8s
```

#### Validate the number of ReplicaSets

```shell
kubectl get replicaset
NAME                DESIRED   CURRENT   READY   AGE
apache-7bd5768c74   0         0         0       32m
apache-869b864c6b   5         5         5       26m
nginx-7854ff8877    7         7         7       5m56s
```

#### List of Deployment's ReplicaSets

```shell
kubectl get replicaset -l app=nginx
NAME               DESIRED   CURRENT   READY   AGE
nginx-7854ff8877   7         7         7       9m1s

kubectl get replicaset -l app=apache
NAME                DESIRED   CURRENT   READY   AGE
apache-7bd5768c74   0         0         0       35m
apache-869b864c6b   5         5         5       30m
```

## Rollout Strategy

- `Rollout Strategy` in Kubernetes that states only a certain number of replicated Pods can be unavailable when rolling out a new version
- A rollout strategy is defined in the Deployment spec.
- If not strategy is defined when the Deployment is created, the default will be applied, which is called `rolling update`.
- The other type of strategy is called `Recreate Strategy`. The `recreate strategy` will terminate the old ReplicaSet Pods before the new ReplicaSet Pods are running.
- The `Recreate Strategy` requires a period of downtime for the application.

### Rolling Update Deployment Definition

```shell
stragety:
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 25%
  type: RollingUpdate
```

## Application Rollout

`Application Rollouts` are a way for a Kubernetes administrator or developer to `roll back` to a previous version, or record the number of versions that the Deployment has.

### View the rollout history

```shell
kubectl rollout history deploy apache
deployment.apps/apache 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

### Record a note along with the deployment

To add a note in the `change-cause` column that says "updated image tag from alpine to 2".

```shell
kubectl annotate deployment apache kubernetes.io/change-cause="updated image tag from alpine to 2"
deployment.apps/apache annotated
```

### Check the rollout history

```shell
kubectl rollout history deploy apache
deployment.apps/apache 
REVISION  CHANGE-CAUSE
1         <none>
2         updated image tag from alpine to 2
```

## Application Rollback

```shell
kubectl rollout undo deploy apache
deployment.apps/apache rolled back
```

### Review the rollout history

- You've reverted to the previous revision, which in turn creates a new revision.
- The revision number will never go backward, it will always go forward.
- You can enter a message into the `change-cause` column for revision 3.

```shell
kubectl rollout history deploy apache
deployment.apps/apache 
REVISION  CHANGE-CAUSE
2         updated image tag from alpine to 2
3         <none>
```

```shell
kubectl annotate deploy apache kubernetes.io/change-cause="reverted back to the original"
deployment.apps/apache annotated
```

### Review the rollout history

```shell
kubectl rollout history deploy apache
deployment.apps/apache 
REVISION  CHANGE-CAUSE
2         updated image tag from alpine to 2
3         reverted back to the original
```

### Validate the status of the rollout

- Maybe the rollout didn't go well.
- Can be possible if the image tag is not available.
- You typed it incorrectly or the image tag is no longer available from your image registry.

```shell
kubectl rollout status deploy apache --revision 3
deployment "apache" successfully rolled out
```

## Pause the Deployment Rollout

- Some of the Pods in the Deployment are on revision 3.
- Half of the Pods are on revision 4.

### Set the Deployment Image and Pause the Rollout

```shell
kubectl set image deploy apache httpd=httpd:2.4 && kubectl rollout pause deploy apache
deployment.apps/apache image updated

deployment.apps/apache paused
```

### Get the Deployment Rollout Status

```shell
kubectl rollout status deploy apache
```

### Resume the Deployment Rollout

```shell
kubectl rollout resume deploy apache
deployment.apps/apache resumed
```

### Check the Deployment Rollout History

```shell
kubectl rollout history deploy apache
deployment.apps/apache 
REVISION  CHANGE-CAUSE
2         updated image tag from alpine to 2
3         reverted back to the original
4         reverted back to the original
```

## Exposing Deployments

### Create the Service Definition

```shell
kubectl expose deploy apache --name apache-svc --port 80 --type ClusterIP --dry-run=client -o yaml > yaml-definitions/apache-svc.yaml
```

### Identify the application to expose

In the `yaml-definitions/apache-svc.yaml` file identify the following section:

```yaml
spec:
  selector:
    app: apache
```

Remove the following configuration from `yaml-definitions/apache-svc.yaml` file:

```yaml
loadBalancer: {}
```

The `selector:` section implements a key-value pairs to search the deployment we are exposing.

### Deploy the service

```shell
kubectl apply -f yaml-definitions/apache-svc.yaml
service/apache-svc created
```

### Validate the service

```shell
kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
apache-svc   ClusterIP   10.101.238.113   <none>        80/TCP    6m33s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   142d
```

## Delete the Deployment

### Delete Nginx Deployment

```shell
kubectl delete deploy nginx
deployment.apps "nginx" deleted
```

### Delete Apache Deployment

```shell
kubectl delete deploy apache
deployment.apps "apache" deleted
```

### Validate Deployments

```shell
kubectl get deploy
No resources found in default namespace.
```

### Validate ReplicaSets

- When the deployment is deleted the associated ReplicaSets are deleted as well.

```shell
kubectl get replicaset
No resources found in default namespace.
```