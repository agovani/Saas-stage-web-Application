# Request a spot instance at $0.03
resource "aws_spot_instance_request" "cheap_worker" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  tags = {
    Name = "CheapWorker"
  }
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
