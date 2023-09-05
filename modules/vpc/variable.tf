variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_subnets_cidr" {
  type = list(any)
}

variable "availability_zones" {
  type = list(any)
}

variable "private_application_subnets_cidr" {
  type = list(any)
}

variable "private_database_subnets_cidr" {
  type = list(any)
}

variable "private_middleware_subnets_cidr" {
  type = list(any)
}