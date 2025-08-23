resource "aws_db_subnet_group" "db" {
  name       = "${var.db}-db-subnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "pg" {
  identifier             = "${lower(replace(var.project, "_", "-"))}-pg"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password # Ensure this variable does not contain /, @, ", or spaces
  db_name                = "appdb"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
}
