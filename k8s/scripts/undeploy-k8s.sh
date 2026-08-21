#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Deleting patient-management resources in default namespace..."

kubectl delete -f "${K8S_DIR}/ingress/" --ignore-not-found
kubectl delete -f "${K8S_DIR}/services/" --ignore-not-found
kubectl delete -f "${K8S_DIR}/infrastructure/" --ignore-not-found
kubectl delete -f "${K8S_DIR}/config/" --ignore-not-found
kubectl delete secret ghcr-pull-secret -n default --ignore-not-found

echo "Kubernetes environment removal complete."
