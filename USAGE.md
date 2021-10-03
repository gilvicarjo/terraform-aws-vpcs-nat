# Using the repo

## 1. Clone project locally
```markdown
git clone https://github.com/gilvicarjo/terraform-aws-vpcs-nat.git
```
## 2. Install Terraform
> https://learn.hashicorp.com/tutorials/terraform/install-cli <br>

- That repo was created with Terraform v0.13.7

## 3. Install AWS CLI in your OS

```markdown
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip -y
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version
```

## 4. The file must follow that structure below
> [Your Profile ID] <br> 
> aws_access_key_id = 'Your Access Key ID' <br>
> aws_secret_access_key = 'Your Secret Access Key'

## 5. Now it's time to play

- From the repo path, inicialize terraform:
```markdown
terraform init
```
- After that, to build the environment, just apply and wait the magic happens
```markdown
terraform apply
```
- Finally, to erase the environment, just
```markdown
terraform destroy
```