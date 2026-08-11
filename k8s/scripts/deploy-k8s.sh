#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
NAMESPACE="patient-management-k8s"
PROFILE="${MINIKUBE_PROFILE:-minikube}"

wait_for_deployment() {
  local deployment="$1"
  local timeout="$2"

  if ! kubectl rollout status "deployment/${deployment}" -n "${NAMESPACE}" --timeout="${timeout}"; then
    echo
    echo "${deployment} did not become ready in time. Showing diagnostics..."
    kubectl get pods -n "${NAMESPACE}" -l "app=${deployment}" -o wide || true
    kubectl describe deployment "${deployment}" -n "${NAMESPACE}" || true
    kubectl describe pods -n "${NAMESPACE}" -l "app=${deployment}" || true
    kubectl logs "deployment/${deployment}" -n "${NAMESPACE}" --tail=160 || true
    exit 1
  fi
}


echo "Deploying patient-management Kubernetes environment..."

kubectl apply -f "${K8S_DIR}/namespace.yaml"
kubectl apply -f "${K8S_DIR}/config/"
kubectl apply -f "${K8S_DIR}/infrastructure/patient-db.yaml"
kubectl apply -f "${K8S_DIR}/infrastructure/auth-db.yaml"
kubectl apply -f "${K8S_DIR}/infrastructure/kafka.yaml"

if kubectl get pod kafka-0 -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "Restarting Kafka pod so the latest StatefulSet template is used..."
  kubectl delete pod kafka-0 -n "${NAMESPACE}" --wait=false
fi

echo "Waiting for databases and Kafka..."
kubectl rollout status statefulset/patient-service-db -n "${NAMESPACE}" --timeout=180s
kubectl rollout status statefulset/auth-service-db -n "${NAMESPACE}" --timeout=180s
if ! kubectl rollout status statefulset/kafka -n "${NAMESPACE}" --timeout=240s; then
  echo
  echo "Kafka did not become ready in time. Showing diagnostics..."
  kubectl get pods -n "${NAMESPACE}" -l app=kafka -o wide || true
  kubectl describe pod kafka-0 -n "${NAMESPACE}" || true
  kubectl logs kafka-0 -n "${NAMESPACE}" --tail=160 || true
  exit 1
fi

kubectl apply -f "${K8S_DIR}/infrastructure/kafdrop.yaml"
kubectl apply -f "${K8S_DIR}/services/billing-service.yaml"
kubectl apply -f "${K8S_DIR}/services/patient-service.yaml"
kubectl apply -f "${K8S_DIR}/services/analytics-service.yaml"
kubectl apply -f "${K8S_DIR}/services/auth-service.yaml"
kubectl apply -f "${K8S_DIR}/services/api-gateway.yaml"
kubectl apply -f "${K8S_DIR}/ingress/"

echo "Waiting for application services..."
wait_for_deployment billing-service 300s
wait_for_deployment patient-service 360s
wait_for_deployment analytics-service 300s
wait_for_deployment auth-service 360s
wait_for_deployment api-gateway 300s
wait_for_deployment kafdrop 300s

echo "Deployment complete."
kubectl get pods,svc,ingress,pvc -n "${NAMESPACE}"

echo
echo "API gateway NodePort: http://$(minikube ip --profile="${PROFILE}"):30080"
echo "Kafdrop NodePort:     http://$(minikube ip --profile="${PROFILE}"):30091"
echo "Optional port-forward: kubectl port-forward svc/api-gateway 4005:4005 -n ${NAMESPACE}"
