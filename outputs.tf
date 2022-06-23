output "nagios-web-output" {
    value = aws_instance.nagios-web.public_dns
}

output "nagios-nrpe-output"{
    value = aws_instance.nagios-nrpe.public_dns
}