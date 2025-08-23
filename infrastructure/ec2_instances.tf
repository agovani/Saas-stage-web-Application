data "aws_ami" "ubuntu_noble" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250821"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project}-web-"
  image_id      = data.aws_ami.ubuntu_noble.id
  instance_type = "t3.small"
  key_name      = "test1"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_cicd_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/pre-config.sh.tpl", {}))
  network_interfaces {
    # Replace with your actual security group resource name, e.g. aws_security_group.web.id
    security_groups = [aws_security_group.web.id]
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "${lower(replace(var.project, "_", "-"))}-web-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn] # <-- Add this line

  tag {
    key                 = "Name"
    value               = "${lower(replace(var.project, "_", "-"))}-web"
    propagate_at_launch = true
  }
}


