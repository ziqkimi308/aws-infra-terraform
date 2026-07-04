output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 web server"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2 web server"
  value       = aws_instance.web.id
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.web.public_ip}"
}