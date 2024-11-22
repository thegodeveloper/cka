# System Roles and Groups

The API server creates a set of default cluster Roles and Cluster Role Bindings. They directly managed by the control plane.

## List System Cluster Roles

```shell
kubectl get clusterrole | grep -v system
```

## Cluster Roles Descriptions

- The `cluster-admin` cluster Role is intended to be used cluster-wide and allows read and write access for most objects, including Roles and Role bindings, with the exception of resources quotas, Endpoints, or the namespace itself.
- The `edit cluster` Role will not allow you to modify Roles or Role bindings, it will allow you to access Secrets and run Pods with any Service Accounts inside the namespace.
- The `view cluster` Role it just like it sounds, allowing you to view most namespaced objects except for Secrets because the contents of a Secret contain the credentials for API access.

## Built-in Default Cluster Role

- The `system:authenticated` group assigns privileges to users who are successfully authenticated.
- The `system:unauthenticated` group is used when none of the authentication plugins can validate the request.
- The `system:masters` group is used for super users and provides unfettered access to everything in Kubernetes.

## Check the current permissions

```shell
kubectl auth can-i --list

Resources                                       Non-Resource URLs   Resource Names   Verbs
*.*                                             []                  []               [*]
                                                [*]                 []               [*]
selfsubjectreviews.authentication.k8s.io        []                  []               [create]
selfsubjectaccessreviews.authorization.k8s.io   []                  []               [create]
selfsubjectrulesreviews.authorization.k8s.io    []                  []               [create]
                                                [/api/*]            []               [get]
                                                [/api]              []               [get]
                                                [/apis/*]           []               [get]
                                                [/apis]             []               [get]
                                                [/healthz]          []               [get]
                                                [/healthz]          []               [get]
                                                [/livez]            []               [get]
                                                [/livez]            []               [get]
                                                [/openapi/*]        []               [get]
                                                [/openapi]          []               [get]
                                                [/readyz]           []               [get]
                                                [/readyz]           []               [get]
                                                [/version/]         []               [get]
                                                [/version/]         []               [get]
                                                [/version]          []               [get]
                                                [/version]          []               [get]
```

## Cluster Role Binding cluster-admin

```shell
kubectl get clusterrolebinding cluster-admin -o yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2024-07-23T22:56:09Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "172"
  uid: 598af3f1-bccd-42ba-9cbe-994bff33e35a
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
```

