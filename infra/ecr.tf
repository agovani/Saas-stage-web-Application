resource "aws_ecr_repository" "Sparkrock-test-demo" {
  name = "spark_rock_demo"
  tags = {
    Name = "latest_sparkrock_demo_ecr"
  }
}
