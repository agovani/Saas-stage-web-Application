resource "aws_secretsmanager_secret" "db_pass" {
  name = "${var.project}-db-pass"
}

resource "aws_secretsmanager_secret_version" "db_pass_value" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "db_url" {
  name = "${var.project}-db-url"
}

resource "aws_secretsmanager_secret_version" "db_url_value" {
  secret_id     = aws_secretsmanager_secret.db_url.id
  secret_string = aws_db_instance.pg.endpoint
}
