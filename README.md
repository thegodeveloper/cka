# Certified Kubernetes Administrator

## Requirements

- Linux.
- Docker Desktop. (With Docker Engine is enough).
- Kind k8s. [here](https://kind.sigs.k8s.io/),
- Terminal, kubectl, vim.

## Notes

- [00 - Create Cluster](notes/00-create-cluster.md)
- [01 - Linux Services](notes/01-linux-services.md)
- [02 - Update Cluster](notes/02-update-cluster.md)
- [03 - Control Plane](notes/03-control-plane.md)
- [04 - Taints & Tolerations](notes/04-taints-tolerations.md)
- [05 - Nodes](notes/05-nodes.md)
- [06 - Data Store etcd](notes/06-datastore-etcd.md)
- [07 - Client & Server Certificates](notes/07-client-and-server-certificates.md)
- [08-  Identity & Access Management](notes/08-identity-and-access-management.md)
- [09 - Roles & Role Bindings](notes/09-roles-and-role-bindings.md)
- [10 - System Roles & Groups](notes/10-system-roles-and-groups.md)
- [11 - Users & Groups](notes/11-users-and-groups.md)
- [12 - Service Accounts](notes/12-service-accounts.md)
- [13 - Scheduling Applications](notes/13-scheduling-applications.md)
- [14 - Using Helm](notes/14-using-helm.md)
- [15 - Resource Request & Limits](notes/15-resource-requests-and-limits.md)
- [16 - Multicontainer Pods](notes/16-multicontainer-pods.md)
- [17 - Init Container](notes/17-init-container.md)
- [18 - ConfigMaps & Secrets](notes/18-configmaps-and-secrets.md)
- [19 - Running Applications in Kubernetes](notes/19-running-applications-in-kubernetes.md)
- [20 - Application Maintenance](notes/20-application-maintenance.md)
- [21 - Adding Application Resources](notes/21-adding-application-resources.md)
- [22 - Communication in Kubernetes Cluster](notes/22-communication-kubernetes-cluster.md)
- [23 - Ingress and Ingress Controllers](notes/23-ingress-and-ingress-controllers.md)
- [24 - Storage in Kubernetes](notes/24-storage-in-kubernetes.md)
- [25 - Install NFS Server](notes/25-install-nfs-server.md)
- [26 - HostPath Implementation with NFS](notes/26-hostpath-implementation-with-nfs.md)
- [27 - Volume in Block Mode](notes/27-volume-in-block-mode.md)
- [28 - Troubleshooting Kubernetes](notes/28-troubleshooting-kubernetes.md)
- [29 - Network Troubleshooting](notes/29-network-troubleshooting.md)
- [30 - Troubleshooting Services](notes/30-troubleshooting-services.md)
- [99 - To Remember](notes/99-to-remember.md)

## Simulators

- [scripts](simulators/scripts.md)

## Labs

- [01 - Contexts - 1%](labs/01-contexts.md)
- [02 - Schedule Pod on Master Node - 3%](labs/02-schedule-pod-on-master-node.md)
- [03 - Scale Down StatefulSet - 1%](labs/03-scale-down-statefulset.md)
- [04 - Pod Ready if Service is Reachable - 4%](labs/04-pod-ready-if-service-is-reachable.md)
- [05 - kubectl Sorting - 1%](labs/05-kubectl-sorting.md)
- [06 - Storage, PV, PVC, Pod Volume - 8%](labs/06-storage-pv-pvc-pod-volume.md)
- [07 - Node and Resource Usage - 1%](labs/07-node-and-resource-usage.md)
- [08 - Get Master Information - 2%](labs/08-get-master-information.md)
- [09 - Kill Scheduler, Manual Scheduling - 5%](labs/09-kill-scheduler-manual-scheduling.md)
- [10 - RBAC ServiceAccount Role RoleBinding - 6%](labs/10-rbac-serviceaccount-role-rolebinding.md)
- [11 - DaemonSet on all Nodes - 4%](labs/11-daemonset-on-all-nodes.md)
- [12 - Deployment on all Nodes - 6%](labs/12-deployment-on-all-nodes.md)
- [13 - Multi Containers and Pod Shared Volume - 4%](labs/13-mult-containers-and-pod-shared-volume.md)
- [14 - Find out Cluster Information - 2%](labs/14-find-out-cluster-information.md)
- [15 - Cluster Event Logging - 3%](labs/15-cluster-event-logging.md)
- [16 - Namespaces and API Resources - 2%](labs/16-namespaces-and-api-resources.md)
- [17 - Find Container of Pod and Check Info - 3%](labs/18-fix-kubelet.md)
- [18 - Fix Kubelet - 8%](labs/18-fix-kubelet.md)
- [19 - Create Secret and Mount into Pod - 3%](labs/19-create-secret-and-mount-into-pod.md)
- [20 - Update Kubernetes Version and Join Cluster - 10%](labs/20-update-kubernetes-version-and-join-cluster.md)
- [21 - Create a Static Pod and Service - 2%](labs/21-create-a-static-pod-and-service.md)
- [22 - Check how long certificates are valid - 2%](labs/22-check-how-long-certificates-are-valid.md)
- [23 - Kubelet client/server cert info - 2%](labs/23-kubelet-client-server-cert-info.md)
- [24 - Network Policy Egress - 9%](labs/24-networkpolicy-egress.md)
- [25 - Etcd Snapshot Save and Restore - 8%](labs/25-etcd-snapshot-save-and-restore.md)
- [26 - HPA Auto-scaling - 6%](labs/26-hpa-auto-scaling.md)
- [27 - Expose Deployment through NodePort - 4%](labs/27-expose-deployment-through-nodeport.md)
- [28 - Pod Troubleshooting - 3%](labs/28-pod-troubleshooting.md)
- [29 - Deploying a Pod with Specifications - 6%](labs/29-deploying-a-pod-with-specifications.md)
- [30 - Schedule Pod in Node - 2%](labs/30-schedule-pod-in-node.md)
- [31 - Network Policy Ingress- 4%](labs/31-networkpolicy-ingress.md)

## ToDo

- Migrate the labs to version `1.31`.
- Add Helm questions.
- Link questions with documentation.


## References

- [Certified Kubernetes Administrator (CKA)](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)
- [Curriculum Overview](https://github.com/cncf/curriculum)
- [Kubectl Quick Reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
