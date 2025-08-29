output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.database_name
}

output "s3_buckets" {
  description = "S3 bucket names"
  value = {
    product_images = module.s3.product_images_bucket_name
    user_uploads   = module.s3.user_uploads_bucket_name
    static_assets  = module.s3.static_assets_bucket_name
  }
}

output "dynamodb_tables" {
  description = "DynamoDB table names"
  value = {
    products      = module.dynamodb.products_table_name
    orders        = module.dynamodb.orders_table_name
    user_sessions = module.dynamodb.user_sessions_table_name
  }
}
