variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_ami" {
  default = "ami-0ea0a27a4a8e7b2b0"
}


variable "vpc_id" {
  default = ""
}


variable "key_name" {
  default = "cba_keypair"
}

