resource "aws_key_pair" "autodeploy" {
  key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_security_group_rule" "restrict_ssh" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["207.81.214.43/32"]
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name_tag,
  }
  
  key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}
