vault_addr = "https://3.70.238.197:8200"  
vault_token = "vault_token"                
vault_namespace = "root"                 
duration = "30s"

test "pki_issue" "rsa_4096_cert_issuance" {
  weight = 100
  config {
    setup_delay = "2s"
    issue {
      name        = "example-dot-com"
      common_name = "test.example.com"
      ttl         = "8670h"
    }
    root_ca {
      ttl = "87600h"
    }

    intermediate_ca {
      ttl = "43800h"
    }
    role {
      ttl = "8760h"
      no_store = false
      generate_lease = false
      key_type = "rsa"
      key_bits = "4096"
    } 	
  }
}
