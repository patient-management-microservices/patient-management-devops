#!/usr/bin/env bash
set -euo pipefail

PROFILE="${MINIKUBE_PROFILE:-minikube}"
CPUS="${MINIKUBE_CPUS:-2}"
MEMORY="${MINIKUBE_MEMORY:-3072}"
DISK_SIZE="${MINIKUBE_DISK_SIZE:-30g}"

echo "Starting Minikube profile: ${PROFILE}"
minikube start \
  --profile="${PROFILE}" \
  --cpus="${CPUS}" \
  --memory="${MEMORY}" \
  --disk-size="${DISK_SIZE}"

echo "Enabling ingress addon for profile: ${PROFILE}"
minikube addons enable ingress --profile="${PROFILE}"

kubectl config use-context "${PROFILE}"

echo "Minikube is ready."
echo "Use this profile with: kubectl config use-context ${PROFILE}"
