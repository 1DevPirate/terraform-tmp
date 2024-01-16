resource "aws_key_pair" "autodeploy" {
  key_name   = "autodeploy"  # Set a unique name for your key pair
# Uncomment if you are running terraform with Jenkins
#  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
# Uncomment if you are running terraform stand alone
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow inbound ssh access"
  vpc_id      = "vpc-00d0891ec7b1c9c7d"

  # Inbound Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.184.200.217/32"]
  }

  # Outbound Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_instance" {
  ami                      = var.ami
  instance_type            = var.instance_type
  key_name                 = aws_key_pair.autodeploy.key_name
  vpc_security_group_ids   = [aws_security_group.ssh_access.id]

  tags = {
    Name = var.name_tag,
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with your instance user
    private_key = file("~/.ssh/id_rsa")  # Specify the path to your private key
    host        = self.public_ip  # Use self.public_ip to get the public IP dynamically
  }

  provisioner "file" {
    source      = "server_prep.sh"
    destination = "/tmp/server_prep.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/server_prep.sh",
      "/tmp/server_prep.sh args",
    ]
  }
}
