# Wiki-project

# ArgoCD GitOps Deployment Repository

This repository contains a complete GitOps setup for deploying applications using ArgoCD with supporting infrastructure components including External DNS, External Secrets, AWS Load Balancer Controller, and monitoring.

## Prerequisites

- Kubernetes cluster (EKS recommended for AWS integrations)
- Helm
- kubectl configured to access your cluster
- Terraform installed
- Appropriate AWS IAM permissions for:
  - AWS Load Balancer Controller
  - External DNS
  - External Secrets (for accessing AWS Secrets Manager/Parameter Store)
  - Loki (for S3 storage)

## Applications Managed

Based on the ArgoCD dashboard, this repository manages the following applications:

- **argocd** - ArgoCD itself (self-managed)
- **aws-alb-controller** - AWS Application Load Balancer Controller
- **clustersecretstore** - External Secrets ClusterSecretStore
- **external-dns** - External DNS for automatic DNS management
- **external-secrets** - External Secrets Operator
- **grafana** - Monitoring and observability
- **loki** - Log aggregation
- **metrics-server** - Kubernetes metrics server
- **prometheus** - Monitoring and alerting
- **promtail** - Log collection agent
- **wiki** - Wiki application

## Deployment Steps

### 1. Deploy Infrastructure with Terraform

You have two options to deploy the infrastructure:

**Option A: Manual Deployment**
Navigate to the `main-infra/` folder and deploy the infrastructure:

```bash
cd main-infra/
terraform init
terraform plan
terraform apply
```

**Option B: GitHub Actions (Recommended)**
Configure GitHub Actions for automated deployment:

1. Set up the following GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Push your changes to trigger the GitHub Actions workflow
3. Monitor the deployment in the Actions tab

The GitHub Actions workflow will automatically run `terraform init`, `terraform plan`, and `terraform apply`. Additionally, it can automatically install ArgoCD if it's not already present in the cluster.

### 2. Install ArgoCD

Install ArgoCD using Helm:

```bash
helm install prod-argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 7.7.23
```

### 3. Configure Repository Access

Apply the repository configuration to allow ArgoCD to access this Git repository:

```bash
kubectl apply -f repo.yaml
```

### 4. Deploy App of Apps

Deploy the root application that will manage all other applications:

```bash
kubectl apply -f root-application.yaml
```

### 5. Deploy ClusterSecretStore

deploy the ClusterSecretStore for External Secrets inside folder apps:

```bash
kubectl apply -f ClusterSecretStore-application.yaml
```
### 6. Deploy manage external-secrets for all applications

Deploy the file secrets-application.yaml inside folder apps:

```bash
kubectl apply -f secrets-application.yaml
```

This configures External Secrets to pull credentials from AWS Secrets Manager/Parameter Store.

### 7. Deploy Wiki Application inside folder apps

Deploy the wiki application which includes:
- **Frontend**: React application
- **Database**: PostgreSQL
- **Security**: Pulls sensitive credentials (DB_USER, DB_PASS, POSTGRES_USER, POSTGRES_PASSWORD) from AWS via External Secrets
- **Configuration**: Non-sensitive data (DB_HOST, DB_NAME, DB_TYPE, DB_PORT) stored in ConfigMaps
- **Load Balancing**: ALB Ingress with SSL certificates
- **Protection**: AWS WAF to protect the application
- **Scaling**: Horizontal Pod Autoscaler (HPA) for automatic scaling
- **Storage**: Persistent volume for PostgreSQL data
WAF

```bash
kubectl apply -f wiki-application.yaml
```

**Configuration Strategy:**
- **Sensitive data** (usernames/passwords): Stored in AWS Secrets Manager and accessed via External Secrets
- **Non-sensitive data** (hostnames, ports, database names): Stored in Kubernetes ConfigMaps

### 8. Customize ArgoCD (Optional)

If you want to customize ArgoCD with specific values:

1. Review the values in the `argocd/` folder
2. Upgrade ArgoCD with your custom values:

```bash
helm upgrade prod-argocd argo/argo-cd \
  --namespace argocd \
  --version 7.7.23 \
  -f argocd/values.yaml
```



## Key Components

### External DNS
Automatically manages DNS records for your applications in AWS Route53.

### External Secrets
Securely manages secrets from AWS Secrets Manager or Systems Manager Parameter Store.

### AWS Load Balancer Controller
Manages AWS Application Load Balancers for Kubernetes ingress resources.

### Monitoring Stack
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation
- **Promtail**: Log collection

### Wiki Application
A sample application demonstrating the deployment pattern.

## GitHub Actions

This repository can optionally use GitHub Actions workflows for automated deployment and CI/CD pipeline management.

## Getting Started

1. Fork this repository
2. Update the repository URL in `repo.yaml` to point to your fork
3. Configure your AWS credentials and Kubernetes context
4. Follow the deployment steps above
5. Access ArgoCD UI to monitor your applications

## Troubleshooting

- Check ArgoCD application status in the UI
- Verify all prerequisites are met
- Ensure proper IAM permissions for AWS integrations
- Check Terraform output for infrastructure deployment issues
