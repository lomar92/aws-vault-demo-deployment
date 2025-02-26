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


### Benchmark Results

| **Metric**                      | **Value** |
|-----------------------------|--------|
| **Test Duration**           | 21,000 seconds (~5.83 hours) |
| **Total Certificates Issued** | 117,352 |
| **Average Issuance Rate**    | 5.59 certificates/sec |
| **Mean Issuance Time**       | 1.79 seconds |
| **95th Percentile**          | 3.96 seconds |
| **99th Percentile**          | 5.49 seconds |
| **Success Rate**             | 100% |

---

## System Performance Observations

### CPU Utilization (Vault Nodes - `c5.12xlarge`)

- **Vault Process Load**: ~**1010%** (equivalent to full utilization of 10 vCPUs)
- **Observation**: RSA-4096 operations are **CPU-intensive**, making high-core instances essential.

### Memory Consumption

- **Available Memory**: ~94 GiB free
- **Vault Process Memory Usage**: ~401 MiB per node
- **Conclusion**: No significant memory bottlenecks detected.

### CPU Utilization Comparison (`t2.micro` vs. `c5.12xlarge`)

| Instance Type  | vCPUs | Memory | Vault CPU Utilization           |
|---------------|-------|--------|--------------------------------|
| `t2.micro`    | 1     | 1 GiB  | ~97.7% (single-core bottleneck) |
| `c5.12xlarge` | 48    | 96 GiB | ~1000% (full utilization of 10 cores) |

---

## Conclusion

- **CPU Dependency**: Vault’s performance for RSA-4096 certificate issuance scales with available CPU power.
- **Recommendation**: For large-scale PKI implementations, high-core instances like `c5.12xlarge` should be used.
- **Performance Replication Cluster**: Deploying a **Performance Replication Cluster** can further enhance throughput by distributing the workload across multiple nodes.
