/*
provider "kubernetes" {
  host                   = "https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443" # Your Sandbox API URL
  token                  = var.openshift_token
  cluster_ca_certificate = base64decode(var.cluster_ca_bundle) # Optional but safer
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-dba-project"
  
}
*/