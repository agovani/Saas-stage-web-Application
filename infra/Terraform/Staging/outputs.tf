output "alb_dns_name" { value = aws_lb.this.dns_name }
output "api_ecr" { value = aws_ecr_repository.api.repository_url }
output "web_ecr" { value = aws_ecr_repository.web.repository_url }
output "db_url" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.pg.endpoint
}
