#These basically just allow easy output of critical
#values / parameters for the current deployment (which in some cases may be
#generated elsewhere and so would otherwise would be hard to find).

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app_repo.name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.app_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app_service.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for application logs"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
  description = "RDS endpoint"
}

output "rds_resource_id" {
  value = aws_db_instance.postgres.resource_id
  description = "RDS resource ID (needed for IAM auth ARN)"
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_db.arn
  description = "ECS task role ARN (needed for RDS IAM auth)"
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
  description = "ECS task execution role ARN"
}
