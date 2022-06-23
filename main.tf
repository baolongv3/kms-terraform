terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
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

resource "aws_security_group" "nagios-web"{
    name = "Nagios Web Security"
    description = "Allow application to be access from the internet"
    vpc_id = aws_vpc.nagios.id

    ingress{
        description = "Allow SSH"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = "22"
        to_port = "22"
    }

}


