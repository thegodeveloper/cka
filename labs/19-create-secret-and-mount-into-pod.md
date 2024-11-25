# Question 19 - Create a Secret and Mount into Pod - 3%

## Use context

```shell
kubectl config use-context kind-k8s-c3
```

## Task Definition

- Do the following in a new Namespace `secret`.
- Create a Pod named `secret-pod` of image `busybox:1.31.1` which should keep running for some time. It should be able to run on master nodes as well, create the proper toleration.
- There is an existing `Secret` at `yaml-definitions/secret1.yaml`, create the `secret` in the Namespace and mount it as readonly into the Pod at `/tmp/secret1`.
- Create a new `Secret` in Namespace `secret` called `secret2` which should contain `user=user1` and `pass=1234`. These entries should be available inside the Pod's container as environment variables `APP_USER` and `APP_PASS`.
- Confirm everything is working.

## Solution

<details>
  <summary>Show the solution</summary>

### Create the Namespace

```shell
k create ns secret
```

### Adjust the Namespace in secret1.yaml file

```shell
cp yaml-definitions/secret1.yaml 19-secret1.yaml
```

```shell
vim 19-secret1.yaml

# append or change namespace to metadata
namespace: secret
``` 

### Apply the file 19-secret1.yaml

```shell
k apply -f 19-secret1.yaml
```

### Create the second secret

```shell
k -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234
```

### Create a Pod template

```shell
k -n secret run secret-pod --image=busybox:1.31.1 -o yaml --dry-run=client -- sh -c "sleep 5d" > 19.yaml
```

### Add tolerations, env variables, volumeMounts and volumes

```shell
vim 19.yaml
```

Append the following configuration to the file:

```yaml
metadata:
  namespace: secret
spec:
  tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
  containers:
  - args:
    ...
    iamge: busybox:1.31.1
    env:
    - name: APP_USER
      valueFrom:
        secretKeyRef:
          name: secret2
          key: user
    - name: APP_PASS
      valueFrom:
        secretKeyRef:
          name: secret2
          key: pass
    volumeMounts:
    - name: secret1
      mountPath: /tmp/secret1
      readOnly: true
  volumes:
  - name: secret1
    secret:
      secretName: secret1
``` 

### Apply the yaml definition

```shell
k apply -f 19.yaml
```

### Check if all is correct

```shell
k -n secret exec secret-pod --env | grep APP
APP_PASS=1234
APP_USER=user1
```

```shell
k -n secret exec secret-pod -- find /temp/secret1
```

```shell
k -n secret exec secret-pod -- cat /tmp/secret1/halt
```

</details>
