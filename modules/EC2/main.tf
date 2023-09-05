resource "aws_instance" "server" {
  ami = var.ec2_ami_id
  availability_zone = var.availability_zone
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_name
  vpc_security_group_ids = [var.ec2_security_group]
  subnet_id = var.subnet_id
  
  tags = {
    Name = var.tag_name
  }
}