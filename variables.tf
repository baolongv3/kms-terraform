variable "cidr_block" {
  description = "Variable containing default CIDR Block for a VPC"
  type = string
  default = "172.16.0.0/16"
}

variable "subnet_cidr_block"{
    description = "Subnet for VPC"
    type = string
    default = "172.16.100.0/24"
}

variable "ssh_pubkey"{
    description = "SSH Public Key"
    type = string
    default = ""
}

variable "instance_type"{
    description = "Instance type for client and nrpe"
    type = string
    default = "t2.micro"
}


variable "availability_zone" {
    description = "Availability Zone for subnet and EBS Volume"
    type = string
    default = "ap-southeast-1c"
}

variable "device_name" {
    description = "Device mountpoint for EBS Drive"
    type = string
    default = "/dev/sdh"
}
