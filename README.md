#This Terraform configuration sets up a VPC with both a public and private EC2 instance.

## Resources Created:
- VPC with a public and private subnet.
- Internet Gateway for the public subnet.
- A public EC2 instance with SSH access.
- A private EC2 instance without public IP.

## Usage:
1. Initialize Terraform: `terraform init`
2. Validate configuration: `terraform validate`
3. Apply configuration: `terraform apply` terraform-cloudformation-aws
