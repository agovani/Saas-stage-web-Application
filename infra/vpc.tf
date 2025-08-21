resource "aws_default_vpc" "Sparkrock-test" {
  tags = {
    Name = "Sparkrock-test"
  }

}

resource "aws_default_subnet" "sparkrock-test-subnet1" {
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Default Subnet for the demo in availability zone a"
  }
}

resource "aws_default_subnet" "sparkrock-test-subnet2" {
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "Default Subnet for the demo in availability zone b"
  }
}

resource "aws_default_subnet" "sparkrock-test-subnet3" {
  availability_zone = "${var.aws_region}c"
  tags = {
    Name = "Default Subnet for the demo in availability zone c"
  }
}
