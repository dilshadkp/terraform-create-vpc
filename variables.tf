#################################
#vpc
#################################

variable "blog-vpc-cidr" {
    default = "172.16.0.0/16"
}

variable "project" {
    default = "dilshad"
}
#################################
#subnets
#################################

variable "public1-cidr" {
    default = "172.16.0.0/19"
}
variable "public2-cidr" {
    default = "172.16.32.0/19"
}
variable "public3-cidr" {
    default = "172.16.64.0/19"
}
variable "private1-cidr" {
    default = "172.16.96.0/19"
}
variable "private2-cidr" {
    default = "172.16.128.0/19"
}
variable "private3-cidr" {
    default = "172.16.160.0/19"
}

#################################
#ec2
#################################
variable "type" {
    default     = "t2.micro"
}

variable "ami" {
    default     = "ami-041d6256ed0f2061c"
}
