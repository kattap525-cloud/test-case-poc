# DynamoDB Table for Products
resource "aws_dynamodb_table" "products" {
  name         = "${var.environment}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"
  range_key    = "category"

  attribute {
    name = "product_id"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  global_secondary_index {
    name            = "CategoryIndex"
    hash_key        = "category"
    range_key       = "name"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.environment}-products"
    Environment = var.environment
  }
}

# DynamoDB Table for Orders
resource "aws_dynamodb_table" "orders" {
  name         = "${var.environment}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"
  range_key    = "user_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "order_date"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIndex"
    hash_key        = "user_id"
    range_key       = "order_date"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.environment}-orders"
    Environment = var.environment
  }
}

# DynamoDB Table for User Sessions
resource "aws_dynamodb_table" "user_sessions" {
  name         = "${var.environment}-user-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "session_id"
  range_key    = "user_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Name        = "${var.environment}-user-sessions"
    Environment = var.environment
  }
}
