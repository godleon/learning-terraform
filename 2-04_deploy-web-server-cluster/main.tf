provider "aws" {
    region = "us-east-2"
}


data "aws_vpc" "default" {
    # 以下屬於 filter 設定
    # 決定要查詢哪些資料用
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}


# 支援資料型態：tring, number, bool, list, map, set, object, tuple, and any
variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default     = 8080
}


resource "aws_instance" "example" {
    ami             = "ami-0c55b159cbfafe1f0"
    instance_type   = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.instance.id ]

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
    EOF

    tags = {
        Name = "terraform-example"
    }
}


resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_launch_configuration" "example" {
    image_id        = "ami-0c55b159cbfafe1f0"
    instance_type   = "t2.micro"
    security_groups = [ aws_security_group.instance.id ]

    user_data       = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
    EOF

    lifecycle {
        # 透過 lifecycle -> create_before_destroy 的設定
        # 由於此資源已經被其他資源給引用，因此變更時會遭到刪除，但因為引用關係而刪除不了
        # 透過變更 resource lifecycle 的方式可以解決此問題
        create_before_destroy = true
    }
}


resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids
    
    min_size = 2
    max_size = 5

    tag {
        key                 = "Name"
        value               = "terraform-asg-example"
        propagate_at_launch = true
    }
}


output "public_ip" {
    value       = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}