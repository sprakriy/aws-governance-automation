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
resource "kubernetes_persistent_volume_claim" "oracle_data" {
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