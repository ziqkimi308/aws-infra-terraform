variable "aws_region" {
	description = "AWS region to deploy resources"
	type = string
	default = "ap-southeast-1"
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type = string
  default = "tf-devops"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID for ap-southeast-1"
  type        = string
  default     = "ami-0497a974f8d5dcef8"
}
