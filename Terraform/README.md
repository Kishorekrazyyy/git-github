# AWS Terraform Instance Setup
This project provides Terraform code to create an AWS EC2 instance. The code defines an AWS provider configuration, sets up an EC2 instance with a specific AMI, instance type, and adds a "linux" tag.

# Installation
Ensure you have Terraform installed on your local machine.
Clone this repository to your local machine.
Configuration
Before running the Terraform code, you need to configure your AWS credentials. Follow the steps below:

# Sign in to the AWS Management Console.
Go to the IAM service and create a new user with programmatic access.
Assign the user appropriate permissions to create EC2 instances.
Take note of the access key and secret key generated for the user.
Once you have the AWS access key and secret key, update the provider "aws" block in the ec2.tf file with your own credentials.

# Usage
## To create the AWS EC2 instance, follow these steps:

+ Open a terminal and navigate to the project directory.
+ Run the following command to initialize Terraform:
-terraform init
+ Run the following command to preview the changes Terraform will make:
-terraform plan
+ If the plan looks good, run the following command to apply the changes and create the EC2 instance:
-terraform apply
+ Confirm the changes by typing yes when prompted.
+ Terraform will provision the AWS resources based on the defined configuration.

