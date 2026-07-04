terraform {
  required_version = ">= 1.0"

  # declaration of providers
  required_providers {
	aws = {
		source = "hashicorp/aws"
		version = "~> 5.0"
	}
  }
}

# expensansion of required_providers
provider "aws" {
  region = var.aws_region
}