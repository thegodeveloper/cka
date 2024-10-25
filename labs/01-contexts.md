# Contexts - 1%

- Write all the contexts names into `contexts.txt` file
- Write a command to display the current context into `context_default_kubectl.sh` using kubectl
- Write a command to display the current context into `context_default_no_kubectl.sh` without using kubectl

## Solution

### Write all the contexts names into contexts.txt file

```shell
k config get-contexts -o name > contexts.txt
```

Or manually:

```shell
k config get-contexts
```

### Write a command to display the current context using kubectl

```shell
kubectl config current-context
docker-desktop
```

```shell
echo 'kubectl config current-context' > context_default_kubectl.sh
chmod u+x context_default_kubectl.sh
./context_default_kubectl.sh
docker-desktop
```

### Write a command to display the current context without using kubectl

```shell
cat ~/.kube/config | grep current | sed -e "s/current-context: //"
docker-desktop
```

```shell
echo 'cat ~/.kube/config | grep current | sed -e "s/current-context: //"' > context_default_no_kubectl.sh
chmod u+x context_default_no_kubectl.sh
./context_default_no_kubectl.sh
docker-desktop
```
