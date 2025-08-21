resource "aws_ecs_task_definition" "Sparkrock_demo_task" {
  family                   = "Sparkrock_demo_tasks"
  container_definitions    = <<DEFINITION
[
  {
    "name": "first-task",
    "image": "${aws_ecr_repository.api.repository_url}",
    "essential": true,
    "portMappings": [
      { "containerPort": 80, "hostPort": 80 },
      { "containerPort": 443, "hostPort": 443 }
    ],
    "memory": 512,
    "cpu": 256,
    "networkMode": "awsvpc",
    "environment": [
      { "name": "DB_HOST", "value": "${aws_db_instance.pg.address}" },
      { "name": "DB_PORT", "value": "5432" },
      { "name": "DB_USER", "value": "${var.db_username}" },
      { "name": "DB_NAME", "value": "${var.db_name}" }
    ],
    "secrets": [
      { "name": "DB_PASS", "valueFrom": "${aws_secretsmanager_secret.db_pass.arn}" },
      { "name": "DB_URL", "valueFrom": "${aws_secretsmanager_secret.db_url.arn}" }
    ]
  }
]
DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  cpu                      = 256
}
