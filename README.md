# Vault Demo Deployment in AWS with Terraform Cloud

This repository provides a Terraform configuration to deploy a **3-node** or **6-node** Vault Enterprise cluster on AWS, configured with **Integrated Storage (Raft)** and **AWS KMS Auto Unseal**.

## Features

- **Automated Deployment**: Uses Terraform Cloud for provisioning.
- **High Availability**: Vault cluster with integrated Raft storage.
- **Security**: Auto Unseal via AWS KMS.
- **Customizable Configuration**: Variables can be adjusted in the `variables.tf` file.
- **Note**: This cluster is intended for **demo or educational purposes only**. Vault must be initialized before use.

---

## Performance Benchmark: RSA 4096 Certificate Issuance

### Test Setup

A benchmark test was conducted to measure the performance of **RSA-4096 certificate issuance** using the `vault-benchmark` tool.

### Vault Cluster Configuration

| **Component**   | **Details**                                      |
|---------------|------------------------------------------------|
| **Instance Type**  | `c5.12xlarge` |
| **vCPUs**  | 48 |
| **Memory**  | 96 GiB |
| **EBS Volume**  | gp3, **100 GiB** |
| **Vault Nodes**  | 6-node Raft cluster |
| **Auto Unseal**  | AWS KMS |

### Benchmark Runner Configuration

| **Instance Type**  | `t3.micro` |
|--------------------|------------|
| **vCPUs**         | 2 |
| **Memory**        | 1 GiB |
| **Purpose**       | Running `vault-benchmark` |

### Benchmark Configuration (config.hcl)

```hcl
vault_addr = "https://<vault_address>:8200"
vault_token = "<vault_token>"
vault_namespace = "root"
duration = "21000s"

test "pki_issue" "rsa_4096_cert_issuance" {
    weight = 100
    config {
        setup_delay = "2s"
        root_ca {
            common_name = "benchmark.test Root Authority"
            key_type = "rsa"
            key_bits = 4096
        }
        intermediate_csr {
            common_name = "benchmark.test Intermediate Authority"
            key_type = "rsa"
            key_bits = 4096
        }
        role {
            ttl = "10s"
            no_store = false
            generate_lease = false
            key_type = "rsa"
            key_bits = 4096
        }
    }
}
