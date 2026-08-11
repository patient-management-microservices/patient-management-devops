# Patient Management Minikube Deployment

This Kubernetes setup is separate from the existing Docker Compose workflow.
The Compose files and Compose scripts remain unchanged.

## Resource Layout

- Namespace: `patient-management-k8s`
- API gateway external access: `NodePort` `30080`
- Kafdrop external access: `NodePort` `30091`
- Internal service discovery uses Kubernetes DNS names such as `patient-service`, `auth-service`, `patient-service-db`, `auth-service-db`, and `kafka`.

## Prerequisites

Install these on the Ubuntu server:

- Docker
- Minikube
- kubectl

Stop the Compose environment before starting Minikube if you want to avoid shared host resource pressure:

```bash
cd patient-management-devops
docker compose down
```

## Start Minikube

```bash
cd patient-management-devops/k8s
./scripts/minikube-start.sh
```

The script starts the default Minikube profile named `minikube`.
You can override its defaults:

```bash
MINIKUBE_CPUS=4 MINIKUBE_MEMORY=8192 ./scripts/minikube-start.sh
```

Default resource settings:

- CPUs: `2`
- Memory: `3072MB`

## Deploy

```bash
cd patient-management-devops/k8s
./scripts/deploy-k8s.sh
```

The deploy script applies resources in this order:

1. Namespace
2. ConfigMap and Secret
3. Postgres databases and Kafka
4. Kafdrop
5. Spring Boot services
6. API gateway
7. Ingress

## Access the Application

Using NodePort:

```bash
minikube ip
curl http://$(minikube ip):30080/api/auth/login
```

Using port-forward:

```bash
kubectl port-forward svc/api-gateway 4005:4005 -n patient-management-k8s
curl http://localhost:4005/api/auth/login
```

Kafdrop:

```bash
http://$(minikube ip):30091
```

On a headless Ubuntu server, open the same URL from a machine that can reach the server, or use SSH port forwarding.

## Optional Ingress Access

Enable ingress with:

```bash
minikube addons enable ingress
```

Map the Minikube IP to the local host name:

```bash
echo "$(minikube ip) patient-management.local" | sudo tee -a /etc/hosts
```

Then use:

```bash
curl http://patient-management.local/api/auth/login
```

## Check Status

```bash
cd patient-management-devops/k8s
./scripts/status.sh
```

Useful manual commands:

```bash
kubectl get pods -n patient-management-k8s
kubectl get svc -n patient-management-k8s
kubectl logs deployment/api-gateway -n patient-management-k8s
kubectl logs deployment/auth-service -n patient-management-k8s
kubectl logs statefulset/kafka -n patient-management-k8s
```

## Remove the Kubernetes Environment

```bash
cd patient-management-devops/k8s
./scripts/undeploy-k8s.sh
```

This removes the `patient-management-k8s` namespace and its namespaced Kubernetes resources.
It does not modify the existing Docker Compose files or scripts.

## Notes

- Database data is stored in Kubernetes PVCs inside Minikube.
- This is a development deployment, not a production-grade Kubernetes setup.
- The current manifests intentionally mirror the existing Compose image tags and environment values.
- Replace the values in `config/app-secrets.yaml` before using this outside a local/dev environment.
