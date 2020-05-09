provider "aws" {
    region = "us-east-2"
}


data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
        bucket          = var.db_remote_state_bucket
        key             = var.db_remote_state_key
        region          = "us-east-2"
    }
}

data "template_file" "user_data" {
    template = file("${path.module}/user-data.sh")

    vars = {
        server_port = var.server_port
        db_address  = data.terraform_remote_state.db.outputs.address
        db_port     = data.terraform_remote_state.db.outputs.port
    }
}


data "aws_vpc" "default" {
    # 以下屬於 filter 設定
    # 決定要查詢哪些資料用
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}


resource "aws_instance" "example" {
    ami             = "ami-0c55b159cbfafe1f0"
    instance_type   = var.instance_type
    vpc_security_group_ids = [ aws_security_group.instance.id ]

    # user_data = <<-EOF
    #     #!/bin/bash
    #     echo "Hello World" > index.html
    #     nohup busybox httpd -f -p ${var.server_port} &
    # EOF

    tags = {
        Name = var.cluster_name
    }
}


resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_launch_configuration" "example" {
    image_id        = "ami-0c55b159cbfafe1f0"
    instance_type   = var.instance_type
    security_groups = [ aws_security_group.instance.id ]

    user_data = data.template_file.user_data.rendered
    # user_data       = <<-EOF
    #     #!/bin/bash
    #     echo "Hello, World" > index.html
    #     nohup busybox httpd -f -p ${var.server_port} &
    # EOF

    lifecycle {
        # 透過 lifecycle -> create_before_destroy 的設定
        # 由於此資源已經被其他資源給引用，因此變更時會遭到刪除，但因為引用關係而刪除不了
        # 透過變更 resource lifecycle 的方式可以解決此問題
        create_before_destroy = true
    }
}
