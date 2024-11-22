# Users and Groups

- Kubernetes API is its own certificate authority.
- It can sign certificates.

## Creating a User

### Generate a private key

```shell
openssl genrsa -out angelina.key 2048
```

### Create a certificate-signing request file

```shell
openssl req -new -key angelina.key -subj "/CN=angelina/O=developers" -out angelina.csr
```

### Store the CSR file in an environment variable

```shell
export REQUEST=$(cat angelina.csr | base64)
```

### Create CertificateSigningRequest

```shell
cat << EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: angelina
spec:
  groups:
  - developers
  request: $REQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```

### Validate the Certificate Signing Request

```shell
kubectl get certificatesigningrequest
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
angelina    25s   kubernetes.io/kube-apiserver-client           kubernetes-admin          <none>              Pending
csr-2rkcv   31m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-cgbrq   31m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
```

### Approve the Request

```shell
kubectl certificate approve angelina
certificatesigningrequest.certificates.k8s.io/angelina approved
```

### Validate the Certificate Signing Request

```shell
kubectl get certificatesigningrequest
NAME        AGE    SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
angelina    4m6s   kubernetes.io/kube-apiserver-client           kubernetes-admin          <none>              Approved,Issued
csr-2rkcv   34m    kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-cgbrq   34m    kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
```

### Extract the contents of the signed certificate

```shell
kubectl get csr angelina -o jsonpath='{.status.certificate}' | base64 -d > angelina.crt
```

### Create the kubeconfig for the user

We have the `angelina.key` and client certificate `angelina.crt files. Use the following command to embed the user configuration to the `kubeconfig` file.

```shell
kubectl config set-credentials angelina --client-key=angelina.key --client-certificate=angelina.crt --embed-certs
User "angelina" set.
```

### Check the credentials for angelina user

```shell
kubectl config view | grep 'name: angelina' -a3
```

### List the contexts

```shell
kubectl config get-contexts

** angelina user is not in the list.
```

#### Add the user to the context

```shell
kubectl config set-context angelina --user=angelina --cluster=kind-cka
Context "angelina" created.
```

Before changing of context, let's create a pod:

```shell
kubectl run nginx --image=nginx --port=80
pod/nginx created
```

#### Switch to angelina context

```shell
kubectl config use-context angelina
Switched to context "angelina".
```

```shell
kubectl get pod
```

```shell
kubectl delete pod nginx
```

## Switch back to kubernetes-admin context

```shell
kubectl config use-context kind-cka                                                                                                                                          ─╯
Switched to context "kind-cka".
```

## Bind a Role to a Group

```shell
kubectl create rolebinding pod-reader-bind --role=pod-reader --group=developers
```

## Resources

- [Create Private Key](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-private-key)
- [Create CertificateSigningRequest](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatessigningrequest)
