provider "aws" {
  region = "Your AWS Zone"
  shared_credentials_file = "~/.aws/credentials" #you can modify your credentials file path
  profile = "Your Profile ID" #the same specified inside the file above
}

terraform {
	required_providers {
		aws = {
        source  = "hashicorp/aws"
	    version = "~> 3.55.0"
		}
  }
}

resource "aws_vpc" "vpc-env-a" {
  cidr_block = "172.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "vpc-env-a"
  }
}

data "aws_availability_zones" "az1" {
  all_availability_zones = true
}
data "aws_availability_zones" "az2" {
  all_availability_zones = true
}

resource "aws_subnet" "subnet-env-a" {
  availability_zone = data.aws_availability_zones.az1.names[0]
  cidr_block = "172.0.0.0/24"
  vpc_id = aws_vpc.vpc-env-a.id
  tags = {
    "Name" = "subnet-env-a"
  }
}

resource "aws_vpc" "vpc-env-b" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "vpc-env-b"
  }
}

resource "aws_subnet" "subnet-env-b" {
  availability_zone = data.aws_availability_zones.az2.names[1]
  cidr_block = "172.16.0.0/24"
  vpc_id = aws_vpc.vpc-env-b.id
  tags = {
    "Name" = "subnet-env-b"
  }
}

resource "aws_subnet" "subnet-env-b2" {
  availability_zone = data.aws_availability_zones.az2.names[2]
  cidr_block = "172.16.1.0/24"
  vpc_id = aws_vpc.vpc-env-b.id
  tags = {
    "Name" = "subnet-env-b2"
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "mb"
  public_key = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
}

resource "aws_security_group" "sg-env-a" {
  name = "SgEnvA"
  description = "Security Group Env A"
  vpc_id = aws_vpc.vpc-env-a.id
  ingress {
      cidr_blocks = ["172.16.0.0/16"]
      from_port = 80
      to_port = 80
      protocol = "tcp"
    }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "sg-env-a"
  }
}

resource "aws_security_group" "sg-env-b-linux" {
  name = "SgEnvBLinux"
  description = "Security Group Env B Linux"
  vpc_id = aws_vpc.vpc-env-b.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "sg-env-b-linux"
  }
}

resource "aws_security_group" "sg-env-b-windows" {
  name = "SgEnvBWindows"
  description = "Security Group Env B Windows"
  vpc_id = aws_vpc.vpc-env-b.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    "Name" = "sg-env-b-windows"
  }
}

resource "aws_instance" "webserver" {
  instance_type = "t2.micro"
  ami = "ami-06602da18c878f98d" 
  subnet_id = aws_subnet.subnet-env-a.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg-env-a.id]
  key_name = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "10"
  }
  user_data = "${file("install_apache.sh")}"
  tags = {
    "Name" = "webserver"
  }
}

output "webserver_private_ip" {
  value = aws_instance.webserver.private_ip
}

resource "aws_instance" "linux" {
  instance_type = "t2.micro"
  ami = "ami-06602da18c878f98d" 
  subnet_id = aws_subnet.subnet-env-b.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg-env-b-linux.id]
  key_name = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "10"
  }
  user_data = "${file("install_packages.sh")}"
  tags = {
    "Name" = "linux"
  }
}

output "linux_private_ip" {
  value = aws_instance.linux.private_ip
}

resource "aws_instance" "windows" {
  instance_type = "t2.micro"
  ami = "ami-08f9f652fbc8a1ace"
  subnet_id = aws_subnet.subnet-env-b2.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg-env-b-windows.id]
  key_name = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "30"
  }
  tags = {
    "Name" = "windows"
  }
}

output "windows_private_ip" {
  value = aws_instance.windows.private_ip
}

resource "aws_internet_gateway" "igw-env-a" {
    vpc_id = aws_vpc.vpc-env-a.id
  tags = {
    "Name" = "igw-env-a"
  }
}

resource "aws_eip" "eip-ngw-env-a" {
  vpc = "true"
  tags = {
    Name = "eip-ngw-env-a"
  }
}

resource "aws_nat_gateway" "ngw-env-a" {
  allocation_id = aws_eip.eip-ngw-env-a.id
  subnet_id = aws_subnet.subnet-env-a.id
  tags = {
    "Name" = "ngw-env-a"
  }
}

resource "aws_eip" "eip-ngw-env-b" {
  vpc = "true"
  tags = {
    Name = "eip-ngw-env-b"
  }
}

resource "aws_nat_gateway" "ngw-env-b" {
  allocation_id = aws_eip.eip-ngw-env-b.id
  subnet_id = aws_subnet.subnet-env-b.id
  tags = {
    "Name" = "ngw-env-b"
  }
}

resource "aws_internet_gateway" "igw-env-b" {
  vpc_id = aws_vpc.vpc-env-b.id
  tags = {
    "Name" = "igw-env-b"
  }
}

resource "aws_route_table" "rt-ngw-env-a" {
  vpc_id = aws_vpc.vpc-env-a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-env-a.id
  }
  route {
    cidr_block = "172.16.0.0/16"
    gateway_id = aws_vpc_peering_connection.peering-env-a-env-b.id
  }
  tags = {
    Name = "rt-env-a"
  }
}

resource "aws_route_table" "rt-ngw-env-b" {
  vpc_id = aws_vpc.vpc-env-b.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-env-b.id
  }
  route {
    cidr_block = "172.0.0.0/16"
    gateway_id = aws_vpc_peering_connection.peering-env-a-env-b.id
  }
  tags = {
    Name = "rt-env-b"
  }
}

resource "aws_route_table_association" "rta-ngw-env-a" {
  subnet_id = aws_subnet.subnet-env-a.id
  route_table_id = aws_route_table.rt-ngw-env-a.id
}

resource "aws_route_table_association" "rta-ngw-env-b" {
  subnet_id = aws_subnet.subnet-env-b.id
  route_table_id = aws_route_table.rt-ngw-env-b.id
}

resource "aws_vpc_peering_connection" "peering-env-a-env-b" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.vpc-env-a.id
  vpc_id        = aws_vpc.vpc-env-b.id
  auto_accept   = true
  tags = {
    Name = "peering-env-a-env-b"
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
}
}

resource "aws_route53_zone" "private" {
  name = "mbio.xyz"

  vpc {
    vpc_id = aws_vpc.vpc-env-a.id
  }

  vpc {
    vpc_id = aws_vpc.vpc-env-b.id
  }
  
}

resource "aws_route53_record" "hw" {
  zone_id = aws_route53_zone.private.id
  name = "hw.mbio.xyz"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.webserver.private_ip]
}
