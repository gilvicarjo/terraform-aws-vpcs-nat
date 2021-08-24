# Using the repo

## 1. Clone project locally
> https://github.com/gilvicarjo/terraform-aws-vpcs-nat.git <br>

## 2. Install Terraform
> https://learn.hashicorp.com/tutorials/terraform/install-cli <br>

- That repo was created with Terraform v0.13.7

## 3. Create the file below to store you AWS Credentials
> "~/.aws/credentials" <br>

- You can modify the way you would like your credentials file path 

## 4. The file must follow that structure below
> [Your Profile ID] <br> 
> aws_access_key_id = 'Your Access Key ID' <br>
> aws_secret_access_key = 'Your Secret Access Key'

## 5. Now it's time to play

- From the repo path, inicialize terraform:
> terraform init

- After that, to build the environment, just apply and wait the magic happens
> terraform apply

- Finally, to erase the environment, just
> terraform destroy