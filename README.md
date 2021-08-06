# Vault Demo Deployment in AWS

3-node Vault Enterprise deployment with Integrated Storage and AWS KMS auto unseal.

The Vault cluster will be initialized and unsealed. After startup run the following commands on you instance:
VAULT_TOKEN=$(cat /etc/vault.d/vaulttoken)
vault login $VAULT_TOKEN

Add variables as needed (see variables.tf).
This cluster is intended for demo or educational purposes only.

