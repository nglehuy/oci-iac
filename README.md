- [OCI IaC (Infrastructure as Code)](#oci-iac-infrastructure-as-code)
    - [Documentation](#documentation)
    - [Installation](#installation)
      - [1. Install Terraform](#1-install-terraform)
      - [2. Install Python Environment](#2-install-python-environment)
      - [3. Install K8s Cluster](#3-install-k8s-cluster)
      - [3. Install Apps](#3-install-apps)
    - [Reference](#reference)

# OCI IaC (Infrastructure as Code)

This repository contains infrastructure code for deploying kubernetes cluster on Oracle Cloud VMs

This is written in [Terraform](https://www.terraform.io/) with custom python scripts.

This uses the [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/) provider.

### Documentation

- [k8s docs](./docs/k8s.md)

### Installation

#### 1. Install Terraform

```bash
brew tap hashicorp/tap
brew install terraform
```

#### 2. Install Python Environment

Make sure the `.venv` is created and activated on every terminal session.

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt -r requirements.dev.txt
```

#### 3. Install K8s Cluster

```bash
cd k8s
terraform init -reconfigure -upgrade
terraform apply
```

#### 3. Install Apps

```bash
# cert-manager
cd apps/cert-manager
terraform init -reconfigure -upgrade
terraform apply

# prometheus
cd apps/prometheus
terraform init -reconfigure -upgrade
terraform apply
```

### Reference

[https://docs.oracle.com/en/learn/oci-oke-multicluster-k8s-terraform/index.html#task-25-create-an-api-key-in-the-oci-console-and-add-the-public-key-to-your-oci-account](https://docs.oracle.com/en/learn/oci-oke-multicluster-k8s-terraform/index.html#task-25-create-an-api-key-in-the-oci-console-and-add-the-public-key-to-your-oci-account)
[https://olav.ninja/deploying-kubernetes-cluster-on-proxmox-part-2](https://olav.ninja/deploying-kubernetes-cluster-on-proxmox-part-2)