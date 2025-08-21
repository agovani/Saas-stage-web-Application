resource "aws_ecs_task_definition" "Sparkrock_demo_task" {
  family                   = "Sparkrock_demo_tasks"
  container_definitions    = <<DEFINITION
[
  {
    "name": "first-task",
    "image": "${aws_ecr_repository.Sparkrock-test-demo.repository_url}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      },
       {
        "containerPort": 443,
        "hostPort": 443
      }
    ],
    "memory": 512,
    "cpu": 256,
    "networkMode": "awsvpc"
  }
]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = 256
}
