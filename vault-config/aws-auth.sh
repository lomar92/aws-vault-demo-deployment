#!/bin/bash

# log into vault 
vault login token=$(cat /etc/vault.d/vaulttoken)

# enable AWS auth method
vault auth enable aws

vault write auth/aws/config/client