#!/usr/bin/env bash
set -euo pipefail

echo "Starting MicroK8s..."
microk8s start

echo "Enabling MicroK8s add-ons (dns, hostpath-storage, ingress)..."
microk8s enable dns hostpath-storage ingress

# Export kubeconfig so standard kubectl commands work seamlessly
mkdir -p ~/.kube
microk8s config > ~/.kube/config

echo "MicroK8s is ready."
echo "You can now run: ./scripts/deploy-k8s.sh"
