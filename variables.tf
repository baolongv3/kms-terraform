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


