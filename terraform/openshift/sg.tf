# This "Data Source" fetches your Default VPC automatically
data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "oracle_sg" {
  name        = "openshift-to-oracle-sg"
  description = "Allow OpenShift Sandbox to reach Oracle RDS"
  vpc_id      = data.aws_vpc.default.id

  # Ingress: Allow OpenShift Sandbox IP
  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
#    cidr_blocks = ["${var.sandbox_ip}/32"] 
    cidr_blocks  = ["52.0.100.174/32"]
    description = "OpenShift Sandbox Egress IP"
  }

  # Egress: Allow all outbound from RDS (standard)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}