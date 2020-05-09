provider "aws" {
    region = "ap-northeast-1"
}


resource "aws_instance" "example" {
    ami             = "ami-00c408a8b71d5c614"
    instance_type   = "t2.micro"

    tags = {
        Name = "terraform-example"
    }
}