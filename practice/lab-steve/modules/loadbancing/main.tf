resource "aws_lb" "three_tier_lb" {
  name = "three-tier-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.lb_sg]
  subnets = var.public_subnets
  idle_timeout = 400 // if in time not connection then clear envirement
  depends_on = [ var.app_sg ]
}

resource "aws_lb_target_group" "three_tier_tg" {
  name = "three-tier-lb-tg"
  port = var.lb_tg_port
  protocol = var.lb_tg_protocol
  vpc_id =  var.vpc_id
  lifecycle {
    ignore_changes = [ name ]
    create_before_destroy = true 
  }
}

resource "aws_lb_listener" "three_tier_lb" {
  load_balancer_arn = aws_lb.three_tier_lb.arn
  port = var.lb_tg_port
  protocol = var.lb_tg_protocol
default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.three_tier_tg.arn
}
}
