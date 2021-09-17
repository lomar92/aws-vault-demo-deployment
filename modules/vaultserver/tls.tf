resource "tls_private_key" "vault" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "vault" {
  key_algorithm   = "${tls_private_key.vault.algorithm}"
  private_key_pem = "${tls_private_key.vault.private_key_pem}"
  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization}"
  }
  dns_names      = [
      "vault-raft.eu-central-1.compute.internal",
      "vault-raft.eu-central-1.compute.amazonaws.com"
      ]
  ip_addresses   = [
     "127.0.0.1"
      ]
}

resource "tls_locally_signed_cert" "vault" {
  cert_request_pem = "${tls_cert_request.vault.cert_request_pem}"

  ca_key_algorithm   = var.algorithm
  ca_private_key_pem = var.private_key_pem
  ca_cert_pem        = var.cert_pem

  validity_period_hours = 12
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}