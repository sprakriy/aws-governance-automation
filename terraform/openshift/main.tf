provider "kubernetes" {
  host  = var.openshift_server
  token = var.openshift_token
  load_config_file = false
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