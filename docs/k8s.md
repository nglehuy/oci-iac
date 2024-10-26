- [Setup kubernetes cluster (OCI)](#setup-kubernetes-cluster-oci)
    - [1. Create OCI api key](#1-create-oci-api-key)
    - [2. Add that API key to the OCI console](#2-add-that-api-key-to-the-oci-console)
    - [3. Collect OCI info](#3-collect-oci-info)
    - [4. Add ssh public key to OCI VMs](#4-add-ssh-public-key-to-oci-vms)
    - [5. Go to subnet of VMs, add option to security list to allow communication between VMs](#5-go-to-subnet-of-vms-add-option-to-security-list-to-allow-communication-between-vms)
    - [6. Goto k8s folder](#6-goto-k8s-folder)
    - [7. Update terraform.tfvars with OCI info, VMs info](#7-update-terraformtfvars-with-oci-info-vms-info)
    - [8. Apply k8s](#8-apply-k8s)
    - [9. \[Optional\] Destroy k8s](#9-optional-destroy-k8s)
- [Access the kubernetes cluster](#access-the-kubernetes-cluster)


# Setup kubernetes cluster (OCI)

**Prerequisites:** `openssl` installed

### 1. Create OCI api key

```bash
openssl genrsa -out oci-api-key.pem 2048
chmod 600 oci-api-key.pem
openssl rsa -pubout -in oci-api-key.pem -out oci-api-key.pub.pem
```

### 2. Add that API key to the OCI console

![OCI api key](./figs/oci-api-key.png)

### 3. Collect OCI info

![OCI config](./figs/oci-api-config.png)

Copy to `~/.oci/config`

Replace `key_file=<path to your private keyfile> # TODO` with the path to your private keyfile `oci-api-key.pem`

### 4. Add ssh public key to OCI VMs

```bash
# ssh to VMs, copy public key to authorized_keys
echo "some-ssh-public-key" >> ~/.ssh/authorized_keys
# check if key is added
cat ~/.ssh/authorized_keys
```

### 5. Go to subnet of VMs, add option to security list to allow communication between VMs

![OCI Instance Subnet](./figs/oci-instance-subnet.png)
![OCI Subnet Security List](./figs/oci-subnet-security-list.png)


### 6. Goto k8s folder

```bash
cd k8s
```

### 7. Update terraform.tfvars with OCI info, VMs info

Get values from OCI console and `~/.oci/config`

`ssh_private_key` is the private key of public key added to VMs in step [4. Add ssh public key to OCI VMs](#4-add-ssh-public-key-to-oci-vms)

```hcl
# terraform.tfvars
ocis = [
  {
    name             = "name"
    user             = "ocid-of-user"
    fingerprint      = "fingerprint-of-oci"
    tenancy          = "ocid-of-tenancy"
    region           = "ap-singapore-1"
    api_key_path     = "/path/to/oci-api-key.pem"
    api_pub_key_path = "/path/to/oci-api-key.pub.pem"
    instances = [
      {
        id               = "ocid1"
        name             = "node-1"
        is_control_plane = true
      },
      {
        id               = "ocid2"
        name             = "node-2"
        is_control_plane = false
      }
    ]
  }
]
ssh_private_key = "/path/to/ssh-private-key" # default is ~/.ssh/id_rsa
```

### 8. Apply k8s

```bash
# inside k8s/ folder
terraform init -reconfigure -upgrade
terraform apply
```

### 9. [Optional] Destroy k8s

```bash
# inside k8s/ folder
terraform destroy
```

# Access the kubernetes cluster

Add ingress rules to security list of controller VM to allow kubectl to access the cluster

![OCI Subnet kubectl](./figs/oci-subnet-kubectl.png)

The follow the reference

Ref: [https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/setting-up-your-first-cluster.md#access-the-kubernetes-cluster](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/setting-up-your-first-cluster.md#access-the-kubernetes-cluster)