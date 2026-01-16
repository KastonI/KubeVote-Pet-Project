# KubeVote — EKS + GitOps + Cloudflare Tunnel

>**DevOps Pet Project**

KubeVote is a “minimally production-ready” Kubernetes platform designed to migrate the **Docker Samples [example-voting-app](https://github.com/dockersamples/example-voting-app)** to Kubernetes using **best practices**, **GitOps**, and **Infrastructure as Code**.

The project runs on **Amazon EKS** (or local Kubernetes) and demonstrates **node autoscaling with Karpenter** and **pod autoscaling with HPA**, following a clean separation of responsibilities between infrastructure and applications.

## Project Goal

The main objective of this project is to demonstrate a **full DevOps lifecycle**:

> **Infrastructure as Code → GitOps deployment → CI/CD automation → Security scanning**

### Core Principles

* **Terraform manages the platform**
* **Argo CD manages applications and cluster state**
* **Git is the single source of truth**
* **No public LoadBalancers — access via Cloudflare Tunnel**

---

### Technology Stack

* **Amazon EKS / Local Kubernetes** — Kubernetes cluster
* **Terraform** — Infrastructure provisioning (S3 backend)
* **Argo CD** — GitOps (App-of-Apps pattern)
* **Karpenter** — Node autoscaling (Spot instances)
* **HPA** — Pod autoscaling
* **Cloudflare** — DNS & Zero Trust
* **Cloudflared Tunnel** — Secure ingress without public LoadBalancers
* **EBS CSI Driver** — Persistent storage (gp3)
* **GitHub Actions** — CI/CD pipelines
* **Trivy + Gitleaks** — Security scanning

---

### Key Components

* **Kubernetes (EKS / local)** — Runtime platform
* **Karpenter** — Automatic scaling of worker nodes (Spot-first)
* **Argo CD** — Declarative GitOps delivery
* **Cloudflare DNS** — Domain and record management
* **Cloudflared Tunnel** — Private access to cluster services
* **PostgreSQL & Redis** — Deployed via Bitnami Helm charts
* **GitHub Actions** — Build, push, update, and scan images

---

## Repository Structure

```text
.
├── terraform/                 # AWS, Cloudflare, and platform bootstrap
│
├── argocd/                    # Argo CD bootstrap
│   ├── applications/          # Argo CD Applications
│   ├── argocd-values.yaml     # Argo CD Helm values
│   └── root-of-app.yaml       # App-of-Apps root
│
├── apps/                      # Application-level Helm charts
│   ├── kube-vote/             # Vote / Result / Worker + Redis / Postgres
│   ├── karpenter-nodepool/    # EC2NodeClass & NodePool
│   └── cloudflared/           # Cloudflared Deployment
│
└── .github/workflows/         # CI/CD + security pipelines
```

---

## CI/CD Flow

* **Matrix build** for multi-architecture images (`amd64`, `arm64`)
* Images are pushed to **GHCR**
* **Immutable image digests** are written to Helm values
* Updates are applied via **GitOps PRs**

### Security Controls

* **Trivy** — container & IaC scanning
* **Gitleaks** — secrets detection
* **SARIF** reports uploaded to GitHub Security
* **Pipeline gates** block critical vulnerabilities and misconfigurations

## How to Run the Project

### 1. Prepare Terraform Backend (S3)

Terraform uses an **S3 backend** (`terraform/backend.tf`).
Create an S3 bucket for the Terraform state and configure it in this file.

---

### 2. Configure Variables (AWS + Cloudflare)

Variables can be provided via:

* `TF_VAR_*` environment variables, or
* a `.tfvars` file

Example structure is available in:

```text
terraform/.example.tfvars
```

Required inputs:

* AWS region and configured `awscli`
* **BCrypt hash** for Argo CD admin password
* Domain registered in Cloudflare
* Cloudflare API token with permissions:

  * **Account**: Tunnel Edit, Zero Trust Edit, Account Settings Read
  * **Zone**: DNS Edit, Zone Edit

---

### 3. Provision Infrastructure with Terraform

From the `terraform/` directory:

```bash
terraform init
terraform apply
```

**You can access Argo CD via argocd.yourdomain.**

#### 3.1 Kubeconfig

If you need to configure kubeconfig use this commands:

```bash
aws eks update-kubeconfig \
  --region <region> \
  --name <cluster_name>

kubectl config use-context \
  arn:aws:eks:<region>:<account_id>:cluster/<cluster_name>
```

---

### 4. Destroy Infrastructure

Before destroying infrastructure, remove Karpenter NodePools to ensure all autoscaled nodes are terminated:

```bash
kubectl delete nodepool --all
```

Verify that only the default node remains:

```bash
kubectl get nodes
```

Then destroy infrastructure:

```bash
terraform destroy
```

---

## Useful Commands

### Access Argo CD UI

You can access Argo CD via argocd.yourdomain or forward the Argo CD server locally:

```bash
kubectl port-forward \
  -n argocd svc/argocd-server 8080:443
```

Open:
[http://localhost:8080](http://localhost:8080)

---

### Test Karpenter & HPA Scaling

Generate load against the voting service:

```bash
kubectl run ab-test \
  --rm -it \
  --restart=Never \
  --namespace=kube-vote \
  --image=jordi/ab \
  -- sh -c \
  'echo "vote=a" > posta && \
   ab -n 1000 -c 50 \
   -p posta \
   -T "application/x-www-form-urlencoded" \
   http://kube-vote-vote:80/'
```

You should observe:

* New pods created by **HPA**
* New nodes provisioned by **Karpenter**

---

## Summary

**KubeVote** is a **portfolio DevOps project**, this project reflects **real-world cloud-native best practices**, suitable for production-like environments and DevOps portfolios.
