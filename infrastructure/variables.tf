variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "SparkRock_Demo"
  type        = string
  default     = "Sparkrock-demo"
}
variable "db" {
  description = "sparkrockdemo"
  type        = string
  default     = "sparkrock-demo"
}

variable "certificate_arn" {
  description = "ACM cert for your domain"
  type        = string
  default     = ""
}

variable "basic_auth_user" {
  default = "admin"
}

variable "basic_auth_pass" {
  default = "vpn123"
}

variable "db_username" {
  default = "SR_Demo_user"
}

variable "db_password" {
  sensitive = true
}

variable "db_name" {
  default = "SR_Demo"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.123.1.0/24", "10.123.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.123.3.0/24", "10.123.4.0/24"]
}

variable "intra_subnets" {
  description = "List of intra subnet CIDR blocks"
  type        = list(string)
  default     = ["10.123.5.0/24", "10.123.6.0/24"]
}
