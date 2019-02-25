provider "aws"
{
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"
region = "${var.region}"
}
resource "aws_vpc" "CustomVPC" {
  cidr_block       = "${var.CidrBlock}"
  enable_dns_hostnames = true
}
resource "aws_subnet" "publicsubnet" {
  vpc_id     = "${aws_vpc.CustomVPC.id}"
  cidr_block = "${var.Subnet_CidrBlock}"
  availability_zone = "${var.az}"
}
resource "aws_internet_gateway" "igw" {
  vpc_id   = "${aws_vpc.CustomVPC.id}"

}
resource "aws_route_table" "rtb" {
  vpc_id           = "${aws_vpc.CustomVPC.id}"
    route {
    cidr_block = "${var.route_cidrblock}"
    gateway_id = "${aws_internet_gateway.igw.id}"
    }
}
resource "aws_route_table_association" "pubsubnet" {
   subnet_id = "${aws_subnet.publicsubnet.id}"
   route_table_id = "${aws_route_table.rtb.id}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  associate_public_ip_address  = true
  security_groups = ["${aws_security_group.common_sg.id}"]

lifecycle {
  create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as_group" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"
  vpc_zone_identifier  = ["${aws_subnet.publicsubnet.id}"]
 
lifecycle {
  create_before_destroy = true
  }
}
resource "aws_elb" "elb" {
  subnets = ["${aws_subnet.publicsubnet.id}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]

 listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
   health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

}


resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = "${aws_autoscaling_group.as_group.id}"
  elb                    = "${aws_elb.elb.id}"
}


resource "aws_security_group" "common_sg" {
  vpc_id = "${aws_vpc.CustomVPC.id}"

  ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
egress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

resource "aws_security_group" "elb_sg" {
  vpc_id = "${aws_vpc.CustomVPC.id}"

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

}

