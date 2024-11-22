#!/bin/zsh

echo '⛔  Deleting Kubernetes clusters CKA simulation\n'
kind delete cluster --name k8s-c1
kind delete cluster --name k8s-c2
kind delete cluster --name k8s-c3
kind delete cluster --name k8s-c4
