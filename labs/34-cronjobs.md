# Question 34 - CronJobs - 2%

## Use context

```shell
kubectl config use-context kind-k8s-c1
```

## Task Definition

- Create a `CronJob` for running every `2 minutes` with `busybox` image.
- The job name should be `my-job` and it should print the current `date and time` to the console.
- After running the job save any one of the pod logs to below path.
- logs.txt

## Solution

<details>
  <summary>Show the solution</summary>

### Validate the CronJob

- Go to the documentation and search for `cronjob`.
- Copy the `cronjob.yaml` example.
- Create a file named `34.yaml`
- Change the name to `my-job`
- Change the `schedule` from "* * * * *" (means every minute) to "*/2 * * * *" (means every 2 minutes).
- Change the `container name` from `hello` to `my-job`.
- The `command` should be `date`. Remove the `echo` command.
- Save the 

Content of the file `34.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: my-job
spec:
  schedule: "*/2 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: my-job
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date
          restartPolicy: OnFailure
```


### Apply the file 33.yaml

```shell
k apply -f 34.yaml
cronjob.batch/my-job created
```

### Validate the CronJob

```shell
k get cronjob my-job
NAME     SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
my-job   */2 * * * *   False     0        <none>          61s
```

### Watch the Pods

```shell
k get pod --watch
NAME                    READY   STATUS      RESTARTS   AGE
application             1/1     Running     0          18m
backend                 1/1     Running     0          18m
frontend                1/1     Running     0          18m
multi-pod               1/1     Running     0          18m
my-job-28874474-rzsrp   0/1     Completed   0          62s
my-job-28874476-l8zv2   0/1     Pending     0          0s
my-job-28874476-l8zv2   0/1     Pending     0          0s
my-job-28874476-l8zv2   0/1     ContainerCreating   0          0s
my-job-28874476-l8zv2   0/1     ContainerCreating   0          0s
my-job-28874476-l8zv2   0/1     Completed           0          0s
my-job-28874476-l8zv2   0/1     Completed           0          2s
my-job-28874476-l8zv2   0/1     Completed           0          2s
my-job-28874476-l8zv2   0/1     Completed           0          2s
my-job-28874476-l8zv2   0/1     Completed           0          3s
^C
```

### Check the logs of any of the Pods

```shell
k logs my-job-28874476-l8zv2
Sun Nov 24 17:16:00 UTC 2024
```

### Create the logs.txt with the logs of any of the Pods

```shell
k logs my-job-28874476-l8zv2 > logs.txt
```

```shell
cat logs.txt
Sun Nov 24 17:16:00 UTC 2024
```

</details>
