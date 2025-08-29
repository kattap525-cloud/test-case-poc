# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${var.environment}-web"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-web-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "msa1" {
  name              = "/ecs/${var.environment}-msa1"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-msa1-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "msa2" {
  name              = "/ecs/${var.environment}-msa2"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-msa2-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "msa3" {
  name              = "/ecs/${var.environment}-msa3"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-msa3-logs"
    Environment = var.environment
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-ecommerce-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.environment}-web-service", "ClusterName", var.ecs_cluster_name],
            [".", ".", ".", "${var.environment}-msa1-service", ".", "."],
            [".", ".", ".", "${var.environment}-msa2-service", ".", "."],
            [".", ".", ".", "${var.environment}-msa3-service", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${var.environment}-web-service", "ClusterName", var.ecs_cluster_name],
            [".", ".", ".", "${var.environment}-msa1-service", ".", "."],
            [".", ".", ".", "${var.environment}-msa2-service", ".", "."],
            [".", ".", ".", "${var.environment}-msa3-service", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeableMemory", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "RDS Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "${var.environment}-redis-cluster"],
            [".", "DatabaseMemoryUsagePercentage", ".", "."],
            [".", "CurrConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ElastiCache Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = "${var.environment}-web-service"
  }

  tags = {
    Name        = "${var.environment}-ecs-cpu-high"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = {
    Name        = "${var.environment}-rds-cpu-high"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors ALB 5XX errors"
  alarm_actions       = []

  tags = {
    Name        = "${var.environment}-alb-5xx-errors"
    Environment = var.environment
  }
}
