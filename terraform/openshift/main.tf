provider "kubernetes" {
  host  = var.openshift_server
  token = var.openshift_token
  insecure = true 
}
resource "kubernetes_secret" "oracle_credentials" {
  metadata {
    name      = "oracle-db-creds"
    namespace = var.openshift_namespace
  }
  data = {
    # This automatically pulls the endpoint from the RDS resource above
    username = aws_db_instance.oracle_db.username
    password = aws_db_instance.oracle_db.password
    endpoint = aws_db_instance.oracle_db.endpoint
  }

  type = "Opaque"
}
resource "kubernetes_persistent_volume_claim_v1" "oracle_data" {
  metadata {
    name      = "oracle-pvc"
    namespace = "my-dba-project"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
# Add this to your main.tf temporarily
output "debug_server_url" {
  value = var.openshift_server
}

# This will force the GitHub Action to tell us what it actually sees
resource "null_resource" "check_vars" {
  provisioner "local-exec" {
    command = "echo 'The server URL being used is: ${var.openshift_server}'"
  }
}