output "products_table_name" {
  description = "Products table name"
  value       = aws_dynamodb_table.products.name
}

output "orders_table_name" {
  description = "Orders table name"
  value       = aws_dynamodb_table.orders.name
}

output "user_sessions_table_name" {
  description = "User sessions table name"
  value       = aws_dynamodb_table.user_sessions.name
}
