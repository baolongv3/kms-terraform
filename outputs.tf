output "nagios-web-output" {
    value = aws_instance.nagios-web.public_ip
}

output "nagios-nrpe-output"{
    value = aws_instance.nagios-nrpe.public_ip
}