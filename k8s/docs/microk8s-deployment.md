# Patient Management MicroK8s Deployment

This Kubernetes setup runs the application microservices using MicroK8s.

## Resource Layout

- Namespace: `default`
- API gateway external access: `NodePort` `30080`
- Kafdrop external access: `NodePort` `30091`
- Internal service discovery uses Kubernetes DNS names such as `patient-service`, `auth-service`, `patient-service-db`, `auth-service-db`, and `kafka`.

## Prerequisites

Install MicroK8s on your Ubuntu / Linux environment:

```bash
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
sudo chown -R $USER ~/.kube
```

## Start MicroK8s & Enable Add-ons

```bash
cd patient-management-devops/k8s
./scripts/microk8s-start.sh
```

This starts MicroK8s, enables `dns`, `hostpath-storage`, and `ingress`, and updates your local `~/.kube/config`.

## Deploy

If your GHCR images are private, export a GitHub username and a token with package read access:

```bash
export GHCR_USERNAME=your-github-username
export GHCR_TOKEN=your-github-token
```

Deploy the application stack:

```bash
cd patient-management-devops/k8s
./scripts/deploy-k8s.sh
```

The deploy script applies resources in this order:

1. ConfigMap and Secret
2. Postgres databases and Kafka
3. Kafdrop
4. Spring Boot microservices
5. API gateway
6. Ingress

## Access the Application

### NodePort
- **API Gateway**: `http://localhost:30080/api/auth/login`
- **Kafdrop**: `http://localhost:30091`

### Ingress Access
Add the mapping to `/etc/hosts`:

```bash
echo "127.0.0.1 patient-management.local" | sudo tee -a /etc/hosts
```

Then access via:

```bash
curl http://patient-management.local/api/auth/login
```

## Check Status

```bash
cd patient-management-devops/k8s
./scripts/status.sh
```

Or view specific resources:

```bash
kubectl get pods -n default
kubectl get svc -n default
kubectl logs deployment/api-gateway -n default
```

## Remove Deployment

```bash
cd patient-management-devops/k8s
./scripts/undeploy-k8s.sh
```

This deletes all deployed resources and persistent volume claims from the `default` namespace.
