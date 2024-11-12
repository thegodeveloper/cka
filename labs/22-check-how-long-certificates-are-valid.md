# Check how long certificates are valid - 2%

## Use context

```shell
kubectl config use-context kind-ks8-c2
```

## Task Definition

- Check how long the `kube-apiserver` server certificate is valid on `k8s-c2-control-plane`. Do this with `openssl` or `cfssl`.
- Write the expiration date into `22-expiration.txt`.
- Also run the correct `kubeadm` command to list the expiration dates and confirm both methods show the same date.
- Write the correct `kubeadm` command that would renew the `apiserver` server certificate to `22-kubeadm-renew-certs.sh`.

## Solution

<details>
  <summary>Show the solution</summary>


</details>
