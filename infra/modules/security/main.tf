# -------------------------
# ALB Security Group
# -------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB SG: allow inbound HTTP and outbound to targets."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from allowed CIDRs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

   ingress {
    description = "Test listener (CodeDeploy) from allowed CIDRs"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

# -------------------------
# ECS Service/Task Security Group
# ------------------------
resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "ECS SG: allow inbound from ALB only."
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from ALB SG"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  /*ingress {
    description = "HTTP test listener (CodeDeploy) from allowed CIDRs"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }*/

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-ecs-sg" })
}

# -------------------------
# RDS Security Group
# -------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "RDS SG: allow inbound DB port from ECS only."
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB port from ECS SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}
