module "vpc" {
    source = "./modules/vpc"
    environment                       = "${var.root_environment}"
    vpc_cidr                          = "${var.root_vpc_cidr}"
    public_subnets_cidr               = "${var.root_public_subnets_cidr}"
    private_application_subnets_cidr  = "${var.root_private_application_subnets_cidr}"
    private_database_subnets_cidr     = "${var.root_private_database_subnets_cidr}"
    private_middleware_subnets_cidr   = "${var.root_private_middleware_subnets_cidr}"
    availability_zones                = tolist([data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]])
}

module "create_security_group" {
  source = "./modules/security_group"
    vpc_id = module.vpc.vpc_id
}

module "create_key_pair" {
  source = "./modules/create_key_pair"
  key_pair_key_name = var.root_key_pair_key_name
  key_pair_path = var.root_key_pair_path
}

module "public_ec2_instance" {
  source = "./modules/EC2"
  #for_each = toset( ["public", "application", "middleware", "database"] )
  ec2_ami_id = var.root_ec2_ami_id
  ec2_instance_type = var.root_ec2_instance_type
  ec2_key_name = module.create_key_pair.pem_key_pair_id
  ec2_security_group = module.create_security_group.public_SG_id
  subnet_id = module.vpc.public_subnet_ids[0]
  tag_name = "public"
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "application_ec2_instance" {
  source = "./modules/EC2"
  #for_each = toset( ["public", "application", "middleware", "database"] )
  ec2_ami_id = var.root_ec2_ami_id
  ec2_instance_type = var.root_ec2_instance_type
  ec2_key_name = module.create_key_pair.pem_key_pair_id
  ec2_security_group = module.create_security_group.application_SG_id
  subnet_id = module.vpc.application_subnet_ids[0]
  tag_name = "application"
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "database_ec2_instance" {
  source = "./modules/EC2"
  #for_each = toset( ["public", "application", "middleware", "database"] )
  ec2_ami_id = var.root_ec2_ami_id
  ec2_instance_type = var.root_ec2_instance_type
  ec2_key_name = module.create_key_pair.pem_key_pair_id
  ec2_security_group = module.create_security_group.database_SG_id
  subnet_id = module.vpc.database_subnet_ids[0]
  tag_name = "database"
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "middleware_ec2_instance" {
  source = "./modules/EC2"
  #for_each = toset( ["public", "application", "middleware", "database"] )
  ec2_ami_id = var.root_ec2_ami_id
  ec2_instance_type = var.root_ec2_instance_type
  ec2_key_name = module.create_key_pair.pem_key_pair_id
  ec2_security_group = module.create_security_group.middleware_SG_id
  subnet_id = module.vpc.middleware_subnet_ids[0]
  tag_name = "middleware"
  availability_zone = data.aws_availability_zones.available.names[0]
}
# output "test" {
#     value = module.vpc.public_subnet_ids[0]
# }
# output "test1" {
#     value = module.vpc.application_subnet_ids[0]
# }