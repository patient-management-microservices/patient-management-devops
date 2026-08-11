#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="patient-management-k8s"

kubectl get pods -n "${NAMESPACE}" -o wide
echo
kubectl get svc -n "${NAMESPACE}"
echo
kubectl get ingress -n "${NAMESPACE}"
echo
kubectl get pvc -n "${NAMESPACE}"
echo
echo "Recent API gateway logs:"
kubectl logs deployment/api-gateway -n "${NAMESPACE}" --tail=80 || true
