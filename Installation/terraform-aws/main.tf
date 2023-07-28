

############################################
#  Providers
############################################

provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAUCTSC6U724TZZWZY"
  secret_key = "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"
}


resource "aws_security_group" "web_access" {
  name        = "web-access security group"
  description = "Allow http and https inbound traffic"

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "sg-gitlab-server" }
}


resource "aws_instance" "gitlab-server" {
  ami           = "ami-00463ddd1036a8eb6" # data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "gitlab-server-key"

  vpc_security_group_ids = [aws_security_group.web_access.id]


  root_block_device {
    delete_on_termination = true
  }

  # TODO: a remote exec to create a pem file in order to do a jump/bastien host 

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("../../gitlab-server-key.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -qq",
      "sudo apt-get install -qq -y vim git wget curl >/dev/null",
      "curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash",
      "sudo apt-get update -qq",
      "export LC_CTYPE=en_US.UTF-8",
      "export LC_ALL=en_US.UTF-8",
      "sudo apt install -y gitlab-ce",
      "sudo gitlab-ctl reconfigure",
    ]
  }



  tags = { Name = "gitlab-server" } #merge({ Name = "vm-public" }, var.tags)
}



output "gitlab-url" {

  value = aws_instance.gitlab-server.public_dns

}



