####################################################
# VPC creation
####################################################

resource "aws_vpc" "blog-vpc" {
  cidr_block            = var.blog-vpc-cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

####################################################
# subnet creation- public1
####################################################
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public1-cidr
  availability_zone         = "ap-south-1a"
  map_public_ip_on_launch   = true
  tags = {
    Name    = "${var.project}-public1"
    Project = var.project
  }
}
####################################################
# subnet creation- public2
####################################################
resource "aws_subnet" "public2" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public2-cidr
  availability_zone         = "ap-south-1b"
  map_public_ip_on_launch   = true

 tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}
####################################################
# subnet creation- public3
####################################################
resource "aws_subnet" "public3" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public3-cidr
  availability_zone         = "ap-south-1c"
  map_public_ip_on_launch   = true
 tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}
####################################################
# subnet creation- private1
####################################################
resource "aws_subnet" "private1" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.private1-cidr
  availability_zone         = "ap-south-1a"

 tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
####################################################
# subnet creation- private2
####################################################
resource "aws_subnet" "private2" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.private2-cidr
  availability_zone         = "ap-south-1b"
 tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}
####################################################
# subnet creation- private3
####################################################
resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.blog-vpc.id
  cidr_block = var.private3-cidr
  availability_zone         = "ap-south-1c"
 tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}

####################################################
# internet gateway
####################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.blog-vpc.id

 tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

####################################################
# elastic IP
####################################################
resource "aws_eip" "eip" {
  vpc      = true
 tags = {
    Name    = "${var.project}-eip"
    Project = var.project
  }
}

####################################################
# NAT
####################################################

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

 tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}

####################################################
# public route table
####################################################

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

####################################################
# private route table
####################################################

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

####################################################
# public route table association
####################################################

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

####################################################
# private route table association
####################################################

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


######################################
#key pair
######################################

resource "aws_key_pair" "terraform" {
  key_name      = "terraform-key"
  public_key    = file("terraform-vpc.pub")
 tags = {
    Name    = "${var.project}-ssh-key"
    Project = var.project
  }
}

######################################
#sg- bastion
######################################

resource "aws_security_group" "bastion" {
  name          = "bastion-sg"
  description   = "allows 22"

ingress = [
    {
      description       = "port 22"
      from_port         = "22"
      to_port           = "22"
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      ipv6_cidr_blocks  = ["::/0"]
      self              = false
      prefix_list_ids   = []
      security_groups   = []
    }
]
egress = [
     {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
     }
]
 tags = {
    Name    = "${var.project}-bastion-sg"
    Project = var.project
}
}
######################################
#sg- webserver
######################################

resource "aws_security_group" "webserver" {
  name          = "webserver-sg"
  description   = "allows 22 from bastion, 80,443 anywhere"

ingress = [
    {
      description       = "port 22"
      from_port         = "22"
      to_port           = "22"
      protocol          = "tcp"
      security_groups   = [ aws_security_group.bastion.id ]
      cidr_blocks       = []
      ipv6_cidr_blocks  = []
      self              = false
      prefix_list_ids   = []
    },
    {
      description       = "port 80"
      from_port         = "80"
      to_port           = "80"
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      ipv6_cidr_blocks  = ["::/0"]
      self              = false
      prefix_list_ids   = []
      security_groups   = []
    },
    {
      description       = "port 443"
      from_port         = "443"
      to_port           = "443"
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      ipv6_cidr_blocks  = ["::/0"]
      self              = false
      prefix_list_ids   = []
      security_groups   = []
    }
]
egress = [
     {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
     }
]
 tags = {
    Name    = "${var.project}-webserver-sg"
    Project = var.project
}

}

######################################
#sg- dbserver
######################################

resource "aws_security_group" "dbserver" {
  name          = "dbserver-sg"
  description   = "allows 22 from bastion, 3306 from webserver"

ingress = [
    {
      description       = "port 22"
      from_port         = "22"
      to_port           = "22"
      protocol          = "tcp"
      security_groups   = [ aws_security_group.bastion.id ]
      cidr_blocks       = []
      ipv6_cidr_blocks  = []
      self              = false
      prefix_list_ids   = []
    },
    {
      description       = "port 3306"
      from_port         = "3306"
      to_port           = "3306"
      protocol          = "tcp"
      security_groups   = [ aws_security_group.webserver.id ]
      cidr_blocks       = []
      ipv6_cidr_blocks  = []
      self              = false
      prefix_list_ids   = []
    }
]
egress = [
     {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
     }
]

 tags = {
    Name    = "${var.project}-dbserver-sg"
    Project = var.project
}

}

######################################
#ec2-bastion
######################################

resource "aws_instance" "bastion" {
    ami                     = var.ami
    instance_type           = var.type
    key_name                = aws_key_pair.terraform.key_name
    vpc_security_group_ids  = [aws_security_group.bastion.id]
 tags = {
    Name    = "${var.project}-bastion"
    Project = var.project
}
}

######################################
#ec2-webserver
######################################

resource "aws_instance" "webserver" {
    ami                     = var.ami
    instance_type           = var.type
    key_name                = aws_key_pair.terraform.key_name
    vpc_security_group_ids  = [aws_security_group.webserver.id]
 tags = {
    Name    = "${var.project}-webserver"
    Project = var.project
}
}

######################################
#ec2-dbserver
######################################

resource "aws_instance" "dbserver" {
    ami                     = var.ami
    instance_type           = var.type
    key_name                = aws_key_pair.terraform.key_name
    vpc_security_group_ids  = [aws_security_group.dbserver.id]
 tags = {
    Name    = "${var.project}-dbserver"
    Project = var.project
}
}
