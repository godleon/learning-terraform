
resource "aws_lb" "example" {
    name                = "terraform-asg-example"
    load_balancer_type  = "application"
    subnets             = data.aws_subnet_ids.default.ids
    security_groups     = [ aws_security_group.alb.id ]
}


resource "aws_lb_listener" "http" {
    load_balancer_arn   = aws_lb.example.arn
    port                = 80
    protocol            = "HTTP"

    # 預設回傳 404 錯誤頁面
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type    = "text/plain"
            message_body    = "404: page not found"
            status_code     = 404
        }
    }
}


resource "aws_lb_listener_rule" "asg" {
    listener_arn    = aws_lb_listener.http.arn
    priority        = 100

    condition {
        field   = "path-pattern"
        values  = ["*"]
    }

    action {
        type                = "forward"
        target_group_arn    = aws_lb_target_group.asg.arn
    }
}


resource "aws_lb_target_group" "asg" {
    name        = "terraform-asg-example"
    port        = var.server_port
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }  
}


resource "aws_security_group" "alb" {
    name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type                = "ingress"
    security_group_id   = aws_security_group.alb.id

    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
    type                = "egress"
    security_group_id   = aws_security_group.alb.id

    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
}