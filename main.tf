terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "blv3-tf-backend"
    key = "terraform-state/key-state"
    region = "ap-southeast-1"
  }
}

//Lookup data

data "aws_ami" "centos"{
    most_recent = true
    filter{
        name = "name"
        values = ["CentOS-7-2111-20220330_2*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["679593333241"]
}

//Network configuration for infrastructure
provider "aws" {
    region = "ap-southeast-1"
}


resource "aws_vpc" "nagios" {
    cidr_block = var.cidr_block
}

resource "aws_subnet" "nagios" {
    vpc_id = aws_vpc.nagios.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
}

resource "aws_internet_gateway" "nagios"{
    vpc_id = aws_vpc.nagios.id
}

resource "aws_route_table" "nagios" {
    vpc_id = aws_vpc.nagios.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.nagios.id
    }

}

resource "aws_route_table_association" "nagios" {
    subnet_id = aws_subnet.nagios.id
    route_table_id = aws_route_table.nagios.id
}


//Security Group for Nagios Configuration

resource "aws_security_group" "nagios-base"{
    name = "Nagios Service base security group"
    description = "Allow application to be access from the internet"
    vpc_id = aws_vpc.nagios.id

    ingress{
        description = "Allow SSH"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = "22"
        to_port = "22"
    }

    ingress {
        description = "Allow HTTP"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = "80"
        to_port = "80"
    }

    ingress {
        description = "Allow HTTPS"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = "443"
        to_port = "443"
    }

    ingress {
        description = "Allow HTTP"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = "80"
        to_port = "80"
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

}

resource "aws_security_group" "nagios-nrpe" {
    name = "Nagios NRPE Security Group"
    description = "Allow NRPE port to be access by nagios client from the same subnet"
    vpc_id = aws_vpc.nagios.id

    ingress {
        description = "Allow NRPE"
        protocol = "tcp"
        from_port= 5666
        to_port=5666
        cidr_blocks = [aws_subnet.nagios.cidr_block]
    }

    ingress {
        description = "Allow ICMP"
        protocol = "icmp"
        from_port = -1
        to_port=-1
        cidr_blocks = [aws_subnet.nagios.cidr_block]
    }
}


//EC2 configuration for infrastructure

resource "aws_key_pair" "kms_key" {
  key_name   = "nagios-kms"
  public_key = var.ssh_pubkey
}




resource "aws_instance" "nagios-web" {
    ami = "ami-0bd717e4b66a1927a"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.nagios-base.id]
    key_name = aws_key_pair.kms_key.key_name
    subnet_id = aws_subnet.nagios.id
    tags = {
        type = "nagios-kms-web"
        terraform = "true"
    }
}


resource "aws_instance" "nagios-nrpe" {
    ami = data.aws_ami.centos.id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.nagios-base.id,aws_security_group.nagios-nrpe.id]
    key_name = aws_key_pair.kms_key.key_name
    subnet_id = aws_subnet.nagios.id
    tags = {
        type = "nagios-kms-nrpe"
        terraform = "true"
    }
}

resource "aws_eip" "nagios-web" {
    instance = aws_instance.nagios-web.id
    vpc = true
}

resource "aws_eip" "nagios-nrpe" {
    instance = aws_instance.nagios-nrpe.id
    vpc = true
}

# EC2 Volume for LVM demo

resource "aws_ebs_volume" "extra-volume"{
    availability_zone = var.availability_zone
    size              = 40
}

resource "aws_volume_attachment" "ebs_att"{
    device_name = var.device_name
    volume_id = aws_ebs_volume.extra-volume.id
    instance_id = aws_instance.nagios-nrpe.id
}