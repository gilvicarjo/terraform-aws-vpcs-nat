# Terraform to build a Sample AWS Environment

## The Environment

All the environment can be destroyed and recreated from scratch if needed.

This repo provisions an internal web site for the company to announce news to theis employees could help with that.

Then, as the diagram below 2 VPCs are provisioned.

> **First VPC**

The first VPC has a Apache Webserver solution that guarantees service availability running in a Linux Server OS.

At the end of the *terraform apply* command you will receive a pem key to connect into this server _from the server at the Second VPC_. 

In this version, we just enable one webpage with the **idolized** 'hello world' as you see at the file *install_apache.sh*

Still regarding the Apache Webserver (could be easily an NGINX, ok!!), it is available only internally in the company on a DNS endpoint. Check it out, in *main.tf* the Terraform resources: aws_route53_zone and aws_route53_record.

Well, both VPCs are being connected by an VPC Peering. 

> **Second VPC**

The Second VPC has an Windows Server OS that can access the webpage available in the First VPC. Inside this instance, some packages as Python, Boto, AWS cli and Terraform, are being installed, just in case. 

<div align="center">"It's Better To Have It And Not Need It, Than To Need It And Not Have It!" <br> Woodrow F. Call </div>
<br>

For further details, you can check the diagram above, the main.tf and even the USAGE.md files.

<br>


## Diagram

## Improved in the Internal Version..

- Provider Inputs
- Availability at Subnet Layer and AZ Layer in both VPCs
- Variables structure