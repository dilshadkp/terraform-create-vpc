output "bastion-publicIP" {
    value = aws_instance.bastion.public_ip
}
output "webserver-publicIP" {
    value = aws_instance.webserver.public_ip
}
output "webserver-privateIP" {
    value = aws_instance.webserver.private_ip
}
output "dbserver-privateIP" {
    value = aws_instance.dbserver.private_ip
}
