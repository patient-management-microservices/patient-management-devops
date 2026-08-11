#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="patient-management-k8s"

echo "Deleting namespace: ${NAMESPACE}"
kubectl delete namespace "${NAMESPACE}" --ignore-not-found

echo "Kubernetes environment removal requested."
echo "This deletes the app resources and namespaced PVCs for the Minikube environment only."
