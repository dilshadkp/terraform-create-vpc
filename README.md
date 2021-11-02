# Terraform script to setup a VPC

In this Terraform script, I am creating a **VPC** with 6 *subnets*(3 public and 3 private) along with an *Internet Gateway*, a *NAT Gateway* and 2 *Route Tables*(1 public and 1 private).

![](https://i.ibb.co/swzJJrn/vpc.png)

## Features
- Fully Automated
- AWS informations are defined using tfvars file and can easily changed (Automated/Manual)
- Each subnet CIDR block created automatically using cidrsubnet Function (Automated)
- Easy to customise and use as the Terraform modules are created using variables,allowing the module to be customized without altering the module's own source code, and allowing modules to be shared between different configurations.
- Project name is appended to the resources that are creating which will make easier to identify the resources.

## Prerequisites
- Create an IAM user on your AWS console that have access to create the required resources.
- Create a dedicated directory where you can create terraform configuration files.
- Install Terraform. [Click here for Terraform installation steps](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
- Knowledge to the working principles of AWS services especially VPC, EC2.
- Knowledge in IP Subnetting.


## Pre-Setup
- Define variable for AWS region in *variables.tf*
```hcl
variable "region" {
    default = "ap-south-1"
}
```
>***region*** <=========== AWS region in which you are going to work
- Configure Provider in *provider.tf*
```hcl
provider "aws" {
    region = var.region
}
```
- Fetching Availability Zones in working AWS region
>This will fetch all available Availability Zones in working AWS region and store the details in variable *az*

```hcl
data "aws_availability_zones" "az" {
  state = "available"
}
```
## 1.Create VPC
- **Define variables for VPC resource in *variables.tf***

```hcl
variable "vpc-cidr" {
    default = "172.16.0.0/16" 
}

variable "project" {
    default = "project_name"
}
```
> ***vpc-cidr*** <================ CIDR block of VPC being created
> 
>  ***project***  <================= Name of the Project



- **Create VPC resource**

```hcl
resource "aws_vpc" "blog-vpc" {
  cidr_block            = var.blog-vpc-cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}
```
## 2.Create Subnets

### Public Subnets
- **Define variable for subnet resources in *variables.tf***
```hcl
variable "vpc-subnet" {
    default = "3"
}
```
> ***vpc-subnet*** <====================== Number of additional bits with which to extend the subnet value of VPC

- Creating public subnet 1

> This will create a subnet in the created VPC with below properties:
> - A Public IP will be assigned by default to an EC2 launched in this Subnet 
>- The availability zone of this Subnet will the First available Availability zone(0th position) in the created VPC
>- CIDR block of this subnet will be the first block of the network(0th position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,0)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-public1"
    Project = var.project
  }
}
```

> ***cidrsubnet()*** in the codes is a function in Terraform for subnetting the CIDR block of VPC and assign the networks among the subnets in that VPC
[click here to know more about cidrsubnet()](https://www.terraform.io/docs/language/functions/cidrsubnet.html)

- Creating public subnet 2

> This will create a subnet in the created VPC with below properties:
>- A Public IP will be assigned by default to an EC2 launched in this Subnet 
>- The availability zone of this Subnet will the Second available Availability zone(1st position) in the created VPC
>- CIDR block of this subnet will be the second block of the network(1st position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,1)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[1]

  tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}
```

- Creating public subnet 3

> This will create a subnet in the created VPC with below properties:
> - A Public IP will be assigned by default to an EC2 launched in this Subnet 
>- The availability zone of this Subnet will the Third available Availability zone(2nd position) in the created VPC
>- CIDR block of this subnet will be the third block of the network(2nd position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,2)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[2]

  tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}
```
### Private Subnets
- Creating private subnet 1

> This will create a subnet in the created VPC with below properties:
> - The availability zone of this Subnet will the First available Availability zone(0th position) in the created VPC
>- CIDR block of this subnet will be the fourth block of the network(3nd position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,3)
  availability_zone         = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
```

- Creating private subnet 2

> This will create a subnet in the created VPC with below properties:
>- The availability zone of this Subnet will the Second available Availability zone(1st position) in the created VPC
>- CIDR block of this subnet will be the fifth block of the network(4th position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,4)
  availability_zone         = data.aws_availability_zones.az.names[1]

  tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}
```

- Creating private subnet 3

> This will create a subnet in the created VPC with below properties:
>- The availability zone of this Subnet will the Third available Availability zone(2nd position) in the created VPC
>- CIDR block of this subnet will be the sixth block of the network(5th position) of VPC after subnetting it with 3 additional bits to the subnet of VPC CIDR

```hcl
resource "aws_subnet" "privat3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,5)
  availability_zone         = data.aws_availability_zones.az.names[1]

  tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}
```
## 3.Create Internet Gateway
>Creating an Internet Gateway and attach it to the created VPC

```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.blog-vpc.id

 tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}
```
## 4.Purchase Elastic IP
> Purchase an Elastic IP from AWS to attach it to the NAT Gateway being created

```hcl
resource "aws_eip" "eip" {
  vpc      = true
 tags = {
    Name    = "${var.project}-eip"
    Project = var.project
  }
}
```
## 5.Create NAT Gateway
>Create a NAT Gateway in any of the public subnets in the VPC(here, it is created in first public subnet in the VPC) to enable Public communication to the instances launched in the private subnets

```hcl
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

 tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}
```
## 6.Create Route Tables
### Create Public Route Table
> Create a public Route table with Route to the outer world(0.0.0.0/0) through the Internet Gateway

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.blog-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
 tags = {
    Name    = "${var.project}-public-rtb"
    Project = var.project
  }
}
```
### Create Private Route Table
> Create a private Route table with Route to the outer world(0.0.0.0/0) through the NAT Gateway


```hcl
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.blog-vpc.id

  route {
      cidr_block        = "0.0.0.0/0"
      nat_gateway_id    = aws_nat_gateway.nat.id
    }
 tags = {
    Name    = "${var.project}-private-rtb"
    Project = var.project
  }
}
```
## 7.Create subnet associations for Route Tables
### Public Route Table Association

> Associate the public subnets with public Route Table

```hcl
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
```
### Private Route Table Association

> Associate the public subnets with public Route Table

```hcl
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
```
#### Lets validate the terraform files using
```hcl
terraform validate
```
#### Lets plan the architecture and verify once again.
```hcl
terraform plan
```
#### Lets apply the above architecture to the AWS.
```hcl
terraform apply
```

- **You can change the values of variables as per your requirement in *vars.tfvars* file and execute the code with *-var-file* option**
