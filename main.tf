resource "aws_key_pair" "autodeploy" {
  key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh_access" {
       name        = "ssh_access"
       description = "Allow inbound ssh access"
       vpc_id      = "vpc-00d0891ec7b1c9c7d"

       # Inbound Access
       ingress {
         from_port   = "22"
         to_port     = "22"
         protocol    = "TCP"
         cidr_blocks = ["207.81.126.111/32"]
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
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name_tag,
  }
  
  key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}
