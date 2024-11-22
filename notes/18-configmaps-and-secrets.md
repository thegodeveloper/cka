# ConfigMaps and Secrets

## ConfigMap

### Create a ConfigMap

```shell
kubectl create configmap redis-config --from-literal=key1=config1 --from-literal=key2=config2 --dry-run=client -o yaml > yaml-definitions/redis-config.yaml
```

### Replace the key-value Pairs and add a Redis Configuration

```shell
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
```

### Create the ConfigMap

```shell
kubectl apply -f yaml-definitions/redis-config.yaml

configmap/redis-config created
```

### Validate the ConfigMap

```shell
kubectl describe configmap redis-config

Name:         redis-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----
maxmemory 2mb
maxmemory-policy allkeys-lru


BinaryData
====

Events:  <none>
```

### Create a Redis Definition File

```shell
kubectl run redis-init --image=redis:7 --port 6379 --command 'redis-server' '/redis-master/redis.conf' --dry-run=client -o yaml > yaml-definitions/redis.yaml
```

### Add a Volume Mount to the Redis File

```shell
resources: {}
volumeMounts:
- mountPath: /redis-master-data
  name: data
- mountPath: /redis-master
  name: config
```

### Add Volumes Configuration

```shell
containers:
volumes:
  - name: data
    emptyDir: {}
  - name: config
    configMap:
      name: redis-config
      items:
      - key: redis-config
        path: redis.conf
```

### Apply the Redis Definition

```shell
kubectl apply -f yaml-definitions/redis.yaml

pod/redis-init created
```

### Validate Redis Pod

```shell
kubectl get pod

NAME         READY   STATUS    RESTARTS   AGE
redis-init   1/1     Running   0          38s
```

### Connect to Redis in the Pod

```shell
kubectl exec -it redis-init -- redis-cli
127.0.0.1:6379>
```

### Get maxmemory Value

```shell
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "2097152"
127.0.0.1:6379>
```

### Get maxmemory-policy Value

```shell
127.0.0.1:6379> CONFIG GET maxmemory-policy
1) "maxmemory-policy"
2) "allkeys-lru"
127.0.0.1:6379>
```

### Delete Pod and ConfigMap

```shell
kubectl delete pod redis-init
pod "redis-init" deleted
```

```shell
kubectl delete cm redis-config
configmap "redis-config" deleted
```

## Secrets

- Secrets are similar to `ConfigMaps` but different in that they store `secret data` instead of application configuration data.
- Secrets values are encoded as Base64 strings and are stored unencrypted by default.

### Create Secret Definition to Mount a Secret as a Volume

```shell
kubectl create secret generic dev-login --from-literal=username=dev --from-literal=password='S!B\*d$zDsb=' --dry-run=client -o yaml > yaml-definitions/dev-login.yaml
```

#### Apply the Secret

```shell
kubectl apply -f yaml-definitions/dev-login.yaml
secret/dev-login created
```

#### Describe the Secret

```shell
kubectl describe secret dev-login

Name:         dev-login
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  12 bytes
username:  3 bytes
```

#### Create Pod Definition to Mount the Secret

```shell
kubectl run secret-pod --image=busybox --command "sh" "c" "echo The app is running! && sleep 3600" --dry-run=client -o yaml > yaml-definitions/secret-pod.yaml
```

#### Change the c to -c

Open the file `yaml-definitions/secret-pod.yaml` and change the `c` to `-c`.

#### Add volumeMounts to the secret-pod

```shell
resources: {}
volumeMounts:
  - name: secret-vol
    readOnly: true
    mountPath: /etc/secret-vol
```

#### Add volumes section (at the same level of containers:)

- The volume type is `secret`, which contains the `dev-login` secret we had previously created.

```shell
containers:
volumes: 
  - name: secret-vol
    secret:
      secretName: dev-login
```

#### Create the secret-pod

```shell
kubectl apply -f yaml-definitions/secret-pod.yaml
pod/secret-pod created
```

#### Validate the secret-pod

```shell
kubectl get pod

NAME         READY   STATUS    RESTARTS   AGE
secret-pod   1/1     Running   0          21s
```

#### Get username and password values from the dev-login secret in secret-pod

```shell
kubectl exec secret-pod -- cat /etc/secret-vol/username && echo
dev

kubectl exec secret-pod -- cat /etc/secret-vol/password && echo
S!B\*d$zDsb=
```

#### Delete the secret-pod

```shell
kubectl delete pod secret-pod
pod "secret-pod" deleted
```

### Use a Secret inside a Pod via an Environment Variable

#### Create the secret-env Definition

```shell
kubectl run secret-env --image=busybox --command "sh" "c" "printenv DEV_USER DEV_PASS; sleep 8200" --env=DEV_PASS=password --dry-run=client -o yaml > yaml-definitions/secret-env.yaml
```

#### Change the c to -c

Open the file `yaml-definitions/secret-env.yaml` and change the `c` to `-c`.

#### Replace the environment variables with the following

```shell
env:
  - name: DEV_USER
    valueFrom:
      secretKeyRef:
        name: dev-login
        key: username
  - name: DEV_PASS
    valueFrom:
      secretKeyRef:
        name: dev-login
        key: password
```

#### Apply the secret-env Definition

```shell
kubectl apply -f yaml-definitions/secret-env.yaml
pod/secret-env created
```

#### Validate the secret-pod

```shell
kubectl get pod

NAME         READY   STATUS    RESTARTS   AGE
secret-env   1/1     Running   0          35s
```

#### Print the container logs

```shell
kubectl logs secret-env
dev
S!B\*d$zDsb=
```

#### Delete the Pod

```shell
kubectl delete pod secret-env
pod "secret-env" deleted
```

### Delete the Secret

```shell
kubectl delete secret dev-login
secret "dev-login" deleted
```