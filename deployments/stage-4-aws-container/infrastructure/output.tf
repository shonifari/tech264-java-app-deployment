
output "app_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.java_app_instance.public_ip
}

output "java-app" {
  value       = "http://${aws_instance.java_app_instance.public_ip}:5000/web/authors"
}

