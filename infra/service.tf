resource "aws_ecs_service" "Sparkrock_demo_services" {
  name                = "SR_demo_first_services"
  cluster             = aws_ecs_cluster.Spark_rock_demo_cluster.id
  task_definition     = aws_ecs_task_definition.Sparkrock_demo_task.arn
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = [aws_default_subnet.sparkrock-test-subnet1.id]
    assign_public_ip = false
  }
}
