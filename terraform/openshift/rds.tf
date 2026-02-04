
# This finds the subnets in your Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# This creates the group required by RDS
resource "aws_db_subnet_group" "default" {
  name       = "main-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "My DB Subnet Group"
  }

}
resource "aws_db_instance" "oracle_db" {
  identifier           = "hero-oracle-db"
  engine               = "oracle-ee" # Oracle Enterprise Edition
  engine_version       = "19"        # Standard 19c
  instance_class       = "db.t3.medium"
  allocated_storage    = 20
  db_name              = "ORCL"
  username             = var.db_username
  password             = var.db_password
  
  # Security
  publicly_accessible  = true        # For lab purposes so OpenShift can reach it
  skip_final_snapshot  = true
  
  # Network - This assumes you have a subnet group from your previous AWS work
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.oracle_sg.id]
}