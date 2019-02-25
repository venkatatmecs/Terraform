variable "access_key" {
  description = "AWS access key"
  default     = ""
}

variable "secret_key" {
  description = "AWS secret key"
  default     = ""
}

variable "region" {
  description = "AWS region which going to launch the resources"
  default     = "us-east-1"
}

variable "CidrBlock" {
  description = "CidrBlock range"
  default     = "192.168.10.0/24"
}

variable "Subnet_CidrBlock" {
  description = "Subnet_CidrBlock"
  default     = "192.168.10.0/24"
}


variable "route_cidrblock" {
  description = "route_cidrblock"
  default     = "0.0.0.0/0"
}

variable "keyname" {
  description = "ssh keyname for ec2 instance"
  default     = "Generickey"
}

variable "az" {
  description = "az"
  default     = "us-east-1a"
}




variable "asg_min_size" {
  description = "min no of instances"
  default     = "2"
}
variable "asg_max_size" {
  description = "maximum no of instances"
  default     = "2"
}
variable "asg_desired_size" {
  description = "capacity of group"
  default     = "5"
}

