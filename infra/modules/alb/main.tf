resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })
}

resource "aws_lb_target_group" "blue" {
  name        = "${var.name}-tg-blue"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg-blue"
  })
}

resource "aws_lb_target_group" "green" {
  name        = "${var.name}-tg-green"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg-green"
  })
}

resource "aws_lb_listener" "prod" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.prod_listener_port
  protocol          = "HTTP"
  lifecycle {
    ignore_changes = [ default_action ]
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener-prod"
  })
}

resource "aws_lb_listener" "test" {
  count             = var.enable_test_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.test_listener_port
  protocol          = "HTTP"
  lifecycle {
    ignore_changes = [ default_action ]
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener-test"
  })
}
