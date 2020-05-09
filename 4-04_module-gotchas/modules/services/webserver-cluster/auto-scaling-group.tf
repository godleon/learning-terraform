
resource "aws_autoscaling_group" "example" {
    launch_configuration    = aws_launch_configuration.example.name
    vpc_zone_identifier     = data.aws_subnet_ids.default.ids

    target_group_arns       = [ aws_lb_target_group.asg.arn ]
    # 這個預設為 EC2
    # 僅有 EC2 instance 完全掛掉時才會不認為不健康
    # 透過 ELB 可以更明確的指定當服務有狀況的時候
    # ASG 就可以開始有動作
    health_check_type       = "ELB"
    
    min_size = var.min_size
    max_size = var.max_size

    tag {
        key                 = "Name"
        value               = var.cluster_name
        propagate_at_launch = true
    }
}