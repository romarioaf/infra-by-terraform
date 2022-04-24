output "instance_public_ip_1" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server_1.public_ip
}