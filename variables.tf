###### Variables ##########

variable "active_key" {
    description = "AccessKey"
    default     = "user"
}

variable "security_key" {
    description = "Secretkey"
    default     = "password"
}

variable "region" {
    description = "EC2 Region for the VPC"
    default     = "ap-south-1"
}

variable "vpc_cidr" {
    description = "VPC cidr block"
    default     = "11.2.0.0/16"
}

variable "public_cidr" {
    description = "public subnet cidr block"
    default     = "11.2.1.0/24"
}

variable "subnet_zone" {
    description = "public availability zone"
    default     = "ap-south-1a"
}

variable "image" {
    description = "instance images"
    default     = "ami-0470e33cd681b2476"
}

variable "instance_type" {
    description = "instance type"
    default     = "t2.micro"
}

variable "key" {
    description = "instance key name"
    default     = "alladamumbai"
}
