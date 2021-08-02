resource "aws_db_instance" "default" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "vaultdb"
  username             = "vault"
  password             = var.vaultdb_password
  skip_final_snapshot  = true
}