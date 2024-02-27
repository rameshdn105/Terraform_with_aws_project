# Terraform_with_aws_project
deploying complete AWS infrastructure setup using Terraform acript
![image](https://github.com/rameshdn105/Terraform_with_aws_project/assets/119552198/95197d54-a685-4113-87b0-8e0f360a9890)
	Pre-requisites:
1.	 AWS account, terraform installed, AWS IAM user(EC2. S3, ALB)
2.	Create keys require to connect with terraform: Access keys 
3.	Have the CLI ready: Could be powershell, CMDER etc.
	AWS CLI, AWS configure: to provie secret id, access key

	Create a folder called Project
mkdir TerraformAC, open it
	Define provider: platform terraform is trying to connect to provision etc.
Ex: AWS provider, Azure provider

-> We are not providing our Access key etc in provider ocnfg as Terraform suggests not to put hardcode values, so we have provided in “AWS configure” command.
	Don’t touch any state file etc, not using any modules in this sessios.
	Create another file main.tf an variables.tf : VPC, subnets, Internet gateway, rules, IAM rule, create s3 bucket.
Step1: Create VPC, 2 subnets in 2 zones, internet gateway and routes which will be attached to VPC.
      - Associate route table to subnet
Step2: Create security group wich will have inbound and outbound rules
Step3: Create S3 bucket.
Step4: Create Loadbalancer with target group and attach each other. 

commands used: 
terraform init
terraform validate
terraform plan
terraform apply
terraform fmt
