output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.centos.id
}

output "key_name" {
  description = "List of key names of instances"
  value       = aws_instance.centos.key_name
}

output "ip" {
  value = aws_eip.ip-im-alive-env.public_ip
}

