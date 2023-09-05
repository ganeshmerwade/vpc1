variable "root_region" {
  type = string
}

variable "root_vpc_cidr" {
  type = string
}

variable "root_environment" {
  type = string
}

variable "root_public_subnets_cidr" {
  type = list(any)
}

variable "root_private_application_subnets_cidr" {
  type = list(any)
}

variable "root_private_database_subnets_cidr" {
  type = list(any)
}

variable "root_private_middleware_subnets_cidr" {
  type = list(any)
}

variable "root_key_pair_key_name" {
  type = string
}

variable "root_key_pair_path" {
  type = string
}

variable "root_ec2_ami_id" {
  type = string
}

variable "root_ec2_instance_type" {
  type = string
}



