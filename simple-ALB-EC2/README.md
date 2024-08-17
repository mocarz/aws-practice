## About the project

This project utilizes Terraform to provision AWS infrastructure, which includes EC2 instances deployed across private subnets in multiple availability zones. An Application Load Balancer (ALB) is implemented to distribute incoming traffic across these instances, which host a simple webpage. Each private subnet is associated with a NAT gateway, with one gateway per availability zone.

## Architecture diagram

![Architecture diagram](doc/diagram-light.svg#gh-light-mode-only)
![Architecture diagram](doc/diagram-dark.svg#gh-dark-mode-only)
