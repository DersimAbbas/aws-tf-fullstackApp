resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs"
  tags = merge(var.tags, { Name = "${var.name}-ecs" })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Name = "/ecs/${var.name}" })
}

# Task execution role (pull from ECR, write logs)
resource "aws_iam_role" "task_exec" {
  name = "${var.name}-ecs-task-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name}-ecs-task-exec" })
}

resource "aws_iam_role_policy_attachment" "task_exec_attach" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  container_definitions = [
    {
      name      = var.container_name
      image     = var.ecr_image
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_USER", value = var.db_user },
        { name = "DB_PASSWORD", value = var.db_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"   
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = var.container_name
        }
      }
    }
  ]
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = tostring(var.cpu)
  memory = tostring(var.memory)

  execution_role_arn = aws_iam_role.task_exec.arn

  container_definitions = jsonencode(local.container_definitions)

  tags = merge(var.tags, { Name = "${var.name}-task" })
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Required for CodeDeploy-managed deployments
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.subnets_public_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.blue_target_group_arn
    container_name   = var.container_name
    container_port   = var.app_port
  }


  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

  tags = merge(var.tags, { Name = "${var.name}-svc" })
}
