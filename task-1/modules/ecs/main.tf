# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.environment}-ecs-cluster"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

# ALB Target Group for Web Application
resource "aws_lb_target_group" "web" {
  name        = "${var.environment}-web-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-web-tg"
    Environment = var.environment
  }
}

# ALB Target Group for Microservices
resource "aws_lb_target_group" "msa1" {
  name        = "${var.environment}-msa1-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/actuator/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-msa1-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "msa2" {
  name        = "${var.environment}-msa2-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/actuator/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-msa2-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "msa3" {
  name        = "${var.environment}-msa3-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/actuator/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-msa3-tg"
    Environment = var.environment
  }
}

# ALB Listener for Web Application
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ALB Listener Rules for Microservices
resource "aws_lb_listener_rule" "msa1" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.msa1.arn
  }

  condition {
    path_pattern {
      values = ["/api/msa1/*"]
    }
  }
}

resource "aws_lb_listener_rule" "msa2" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.msa2.arn
  }

  condition {
    path_pattern {
      values = ["/api/msa2/*"]
    }
  }
}

resource "aws_lb_listener_rule" "msa3" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.msa3.arn
  }

  condition {
    path_pattern {
      values = ["/api/msa3/*"]
    }
  }
}

# ECS Task Definition for Web Application
resource "aws_ecs_task_definition" "web" {
  family                   = "${var.environment}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "web-app"
      image = var.web_server_image
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}-web"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-web-task"
    Environment = var.environment
  }
}

# ECS Task Definition for MSA1
resource "aws_ecs_task_definition" "msa1" {
  family                   = "${var.environment}-msa1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "msa1"
      image = var.msa1_image
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}-msa1"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-msa1-task"
    Environment = var.environment
  }
}

# ECS Task Definition for MSA2
resource "aws_ecs_task_definition" "msa2" {
  family                   = "${var.environment}-msa2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "msa2"
      image = var.msa2_image
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}-msa2"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-msa2-task"
    Environment = var.environment
  }
}

# ECS Task Definition for MSA3
resource "aws_ecs_task_definition" "msa3" {
  family                   = "${var.environment}-msa3"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "msa3"
      image = var.msa3_image
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}-msa3"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-msa3-task"
    Environment = var.environment
  }
}

# ECS Service for Web Application
resource "aws_ecs_service" "web" {
  name            = "${var.environment}-web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web-app"
    container_port   = 8080
  }

  # Force new deployment when task definition changes (e.g., new image)
  triggers = {
    task_definition = aws_ecs_task_definition.web.revision
  }

  depends_on = [aws_lb_listener.web]

  tags = {
    Name        = "${var.environment}-web-service"
    Environment = var.environment
  }
}

# ECS Service for MSA1
resource "aws_ecs_service" "msa1" {
  name            = "${var.environment}-msa1-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.msa1.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.msa1.arn
    container_name   = "msa1"
    container_port   = 8080
  }

  # Force new deployment when task definition changes (e.g., new image)
  triggers = {
    task_definition = aws_ecs_task_definition.msa1.revision
  }

  tags = {
    Name        = "${var.environment}-msa1-service"
    Environment = var.environment
  }
}

# ECS Service for MSA2
resource "aws_ecs_service" "msa2" {
  name            = "${var.environment}-msa2-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.msa2.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.msa2.arn
    container_name   = "msa2"
    container_port   = 8080
  }

  # Force new deployment when task definition changes (e.g., new image)
  triggers = {
    task_definition = aws_ecs_task_definition.msa2.revision
  }

  tags = {
    Name        = "${var.environment}-msa2-service"
    Environment = var.environment
  }
}

# ECS Service for MSA3
resource "aws_ecs_service" "msa3" {
  name            = "${var.environment}-msa3-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.msa3.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.msa3.arn
    container_name   = "msa3"
    container_port   = 8080
  }

  # Force new deployment when task definition changes (e.g., new image)
  triggers = {
    task_definition = aws_ecs_task_definition.msa3.revision
  }

  tags = {
    Name        = "${var.environment}-msa3-service"
    Environment = var.environment
  }
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for ECR access
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.environment}-ecr-access-policy"
  description = "Policy for ECS tasks to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# DynamoDB Access Policy for ECS Tasks
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.environment}-dynamodb-access-policy"
  description = "Policy for ECS tasks to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.environment}-*"
        ]
      }
    ]
  })
}

# S3 Access Policy for ECS Tasks
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.environment}-s3-access-policy"
  description = "Policy for ECS tasks to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-*",
          "arn:aws:s3:::${var.environment}-*/*"
        ]
      }
    ]
  })
}

# Attach DynamoDB policy to ECS task role
resource "aws_iam_role_policy_attachment" "dynamodb_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# Attach S3 policy to ECS task role
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Auto Scaling for ECS Services
resource "aws_appautoscaling_target" "web" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web" {
  name               = "${var.environment}-web-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Similar auto-scaling for microservices
resource "aws_appautoscaling_target" "msa1" {
  max_capacity       = 8
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.msa1.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "msa1" {
  name               = "${var.environment}-msa1-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.msa1.resource_id
  scalable_dimension = aws_appautoscaling_target.msa1.scalable_dimension
  service_namespace  = aws_appautoscaling_target.msa1.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
