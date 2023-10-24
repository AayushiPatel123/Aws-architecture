resource "aws_security_group" "app_security_group" {
  name        = "app-security-group"
  description = "My Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress{
    from_port = 3309
    to_port = 3309
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_security_group"
  }
}

resource "aws_launch_template" "launch_template"{
    name = "launch_template"
    image_id = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.app_security_group.id]
}

resource "aws_autoscaling_group" "asg_1"{
    name = "app_asg_1"
    max_size = 2
    min_size = 2
    vpc_zone_identifier = [aws_subnet.app_private_subnet_az1.id, aws_subnet.app_private_subnet_az2.id]

    launch_template {
        id = aws_launch_template.launch_template.id
        version = aws_launch_template.launch_template.latest_version
    }
    tag {
        key = "Name"
        value = "app_instance"
        propagate_at_launch = true
    }
}