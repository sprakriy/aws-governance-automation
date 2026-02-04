variable "openshift_server" {
  type        = string
  description = "The API URL of your OpenShift Sandbox"
  default     = "https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443"
}

variable "openshift_token" {
  type        = string
  sensitive   = true
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "openshift_namespace" {
  type        = string
  description = "Your specific sandbox namespace (e.g., yourname-dev)"
  default    = "shankar-prakriya-dev"
}