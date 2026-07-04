# vpc module cannot access root main variables, so we need to pass from here
module "vpc" {
  source = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  aws_region = var.aws_region
}

# Security Group
resource "aws_security_group" "ec2" {
  name = "${var.project_name}-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id = module.vpc.vpc_id
  
  ingress {
	description = "SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Alow all outbound traffics from EC2 to internet
  egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "web" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name = aws_key_pair.main.key_name

  user_data = <<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get install -y apache2
  systemctl enable --now apache2
  echo "<h1>Provisioned by Terraform</h1>" > /var/www/html/index.html
  EOF

	tags = {
	  Name = "${var.project_name}-web-server"
	  Environment = "dev"
	}
}