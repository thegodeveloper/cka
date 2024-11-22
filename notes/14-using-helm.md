# Using Helm

## Install Helm in macOS

```shell
brew install helm
```

## Validate the Helm installation

```shell
helm version --short
```

## Add Helm Chart Repository

```shell
helm repo add hashicorp https://helm.releases.hashicorp.com
```

## List Helm Repositories

```shell
helm repo list
```

## Search in the repositories

In the following command we are searching for `vault` in the repositories. (in this example we found two repositories with `vault` available).

```shell
helm search repo vault

NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
bitnami-repo/vault                      1.4.10          1.17.1          Vault is a tool for securely managing and acces...
hashicorp/vault                         0.28.1          1.17.2          Official HashiCorp Vault Chart                    
hashicorp/vault-secrets-operator        0.8.1           0.8.1           Official Vault Secrets Operator Chart
```

## Add MetalLB Repository

```shell
helm repo add metallb https://metallb.github.io/metallb
```

### Search for metallb

```shell
helm search repo metallb
```

### Apply a values file to a Helm Chart

Get the `kind Docker bridge CIDR`:

```shell
docker network inspect -f '{{.IPAM.Config}}' kind

[{172.18.0.0/16  172.18.0.1 map[]} {fc00:f853:ccd:e793::/64  fc00:f853:ccd:e793::1 map[]}]
```

Install the MetalLB Helm Chart

```shell
helm install metallb metallb/metallb --values yaml-definitions/helm-values.yaml

NAME: metallb
LAST DEPLOYED: Tue Aug 27 18:13:44 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
MetalLB is now running in the cluster.

Now you can configure it via its CRs. Please refer to the metallb official docs
on how to use the CRs.
```

### Validate the MetalLB installation

```shell
helm list

NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
metallb default         1               2024-08-27 18:13:44.511928 -0500 -05    deployed        metallb-0.14.8  v0.14.8
```

## Uninstall MetalLB from the cluster

```shell
helm delete metallb

release "metallb" uninstalled
```
