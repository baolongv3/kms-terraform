output "nagios-web-instance-id"{
    value = aws_instance.nagios-web.id
}
output "nagios-web-ip" {
    value = aws_instance.nagios-web.public_ip
}

output "nagios-nrpe-instance-id"{
    value = aws_instance.nagios-nrpe.id
}
output "nagios-nrpe-ip"{
    value = aws_instance.nagios-nrpe.public_ip
}

