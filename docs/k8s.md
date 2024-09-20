- [Setup kubernetes cluster (OCI)](#setup-kubernetes-cluster-oci)
    - [1. Create OCI api key](#1-create-oci-api-key)
    - [2. Create a new API key in the OCI console](#2-create-a-new-api-key-in-the-oci-console)
    - [3. Collect OCI info](#3-collect-oci-info)
    - [4. Update terraform.tfvars with OCI info, VMs info](#4-update-terraformtfvars-with-oci-info-vms-info)
    - [5. Apply k8s](#5-apply-k8s)
    - [6. \[Optional\] Destroy k8s](#6-optional-destroy-k8s)


# Setup kubernetes cluster (OCI)

**Prerequisites:** `openssl` installed

### 1. Create OCI api key

```bash
openssl genrsa -out oci-api-key.pem 2048
chmod 600 oci-api-key.pem
openssl rsa -pubout -in oci-api-key.pem -out oci-api-key.pub.pem
```

### 2. Create a new API key in the OCI console

![OCI api key](./figs/oci-api-key.png)

Copy to `~/.oci/config`:

![OCI config](./figs/oci-api-config.png)

Replace `key_file=<path to your private keyfile> # TODO` with the path to your private keyfile `oci-api-key.pem`

### 3. Collect OCI info

![OCI info](./figs/oci-info.png)

### 4. Update terraform.tfvars with OCI info, VMs info

### 5. Apply k8s

```bash
terraform init -reconfigure -upgrade
terraform apply -auto-approve
```

### 6. [Optional] Destroy k8s

```bash
terraform destroy -auto-approve
```