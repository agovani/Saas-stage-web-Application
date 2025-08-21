data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"

  user_data = base64encode(file("${path.module}/pre-config.sh"))

  security_group_names = [aws_security_group.ecs.name]
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project}-ecs-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [aws_default_subnet.sparkrock-test-subnet1.id]
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.project}-ecs-instance"
    propagate_at_launch = true
  }
}
