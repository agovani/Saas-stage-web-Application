resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project}-api"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${var.project}-web"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/ec2/${var.project}-instances"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/alb/${var.project}-alb"
  retention_in_days = 14
}


resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "EC2 CPU utilization is above 70%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  treat_missing_data = "notBreaching"
}
