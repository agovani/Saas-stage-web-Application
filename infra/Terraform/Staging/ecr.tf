resource "aws_ecr_repository" "api" {
  name = "${var.project}-api"
}

resource "aws_ecr_repository" "web" {
  name = "${var.project}-web"
}
