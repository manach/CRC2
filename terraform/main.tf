terraform {
  cloud {
    organization = "ccsdev"

    workspaces {
      name = "CRC2"
    }
  }
}

provider "aws" {
    region = "us-east-1" 
}

resource "aws_instance" "CRC2_iac" {
    # creates 2 identical EC2s
    count = 2

    ami             = "${data.aws_ami.latest_rhel.id}"
    instance_type   = "t2.micro"
    security_groups = [
        aws_security_group.standard_ports.name
]

    user_data = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    EOT
    tags = {
        Name = "CRC2_iac_${count.index}"
    }
}

resource "aws_security_group" "standard_ports" {
    name        = "standard_ports"
    description = "Allow me only to 22, all to 80 and 443"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["70.124.184.50/32"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_ami" "latest_rhel" {
    most_recent = true
    owners = ["309956199498"] // Red Hat's account ID.
    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "name"
        values = ["RHEL-8*"]
    }
}


