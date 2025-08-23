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
  alarm_name        = "CPU utilization 70%"
  alarm_description = ""
  namespace         = "AWS/EC2"
  metric_name       = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  period                    = 300
  statistic                 = "Maximum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = 70
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  treat_missing_data        = "missing"
  actions_enabled           = true
  alarm_actions             = ["arn:aws:sns:us-east-1:606010181709:Default_CloudWatch_Alarms_Topic"]
  insufficient_data_actions = []
  ok_actions                = []
  tags                      = {}
}
