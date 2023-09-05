/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "${var.environment}-nat"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,count.index)}"
  availability_zone       = "${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-public-subnet"
    type        = "public"
    Environment = "${var.environment}"
  }
}

/* Private application subnet */
resource "aws_subnet" "private_application_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_application_subnets_cidr)}"
  cidr_block              = "${element(var.private_application_subnets_cidr,count.index)}"
  availability_zone       = "${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-app-pvt-subnet"
    type        = "application"
    Environment = "${var.environment}"
  }
}

/* Private database subnet */
resource "aws_subnet" "private_database_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_database_subnets_cidr)}"
  cidr_block              = "${element(var.private_database_subnets_cidr,count.index)}"
  availability_zone       = "${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-db-pvt-subnet"
    type        = "database"
    Environment = "${var.environment}"
  }
}

/* Private middleware subnet */
resource "aws_subnet" "private_middleware_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_middleware_subnets_cidr)}"
  cidr_block              = "${element(var.private_middleware_subnets_cidr,count.index)}"
  availability_zone       = "${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-mw-pvt-subnet"
    type       = "middleware"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private_application" {
  count          = "${length(var.private_application_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_application_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_database" {
  count          = "${length(var.private_database_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_database_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_middleware" {
  count          = "${length(var.private_middleware_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_middleware_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

/*==== NACL for application subnet ======*/
resource "aws_network_acl" "application" {
  vpc_id = aws_vpc.vpc.id

egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.24.0/23"
    from_port  = "0"
    to_port    = "0"
  }
  egress {
    protocol   = "-1"
    rule_no    = 99
    action     = "allow"
    cidr_block = "10.0.26.0/23"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 98
    action     = "allow"
    cidr_block = "10.0.24.0/23"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 97
    action     = "allow"
    cidr_block = "10.0.26.0/23"
    from_port  = "0"
    to_port    = "0"
  }

egress {
    protocol   = "-1"
    rule_no    = 96
    action     = "allow"
    cidr_block = "10.0.28.0/22"
    from_port  = "0"
    to_port    = "0"
  }
  egress {
    protocol   = "-1"
    rule_no    = 95
    action     = "allow"
    cidr_block = "10.0.32.0/22"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 94
    action     = "allow"
    cidr_block = "10.0.28.0/22"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 93
    action     = "allow"
    cidr_block = "10.0.32.0/22"
    from_port  = "0"
    to_port    = "0"
  }  

 egress {
    protocol   = "tcp"
    rule_no    = 92
    action     = "allow"
    cidr_block = "10.0.0.0/25"
    from_port  = "8080"
    to_port    = "8085"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 91
    action     = "allow"
    cidr_block = "10.0.0.0/25"
    from_port  = "8080"
    to_port    = "8085"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 90
    action     = "allow"
    cidr_block = "10.0.1.0/25"
    from_port  = "8080"
    to_port    = "8085"
  }
  egress {
    protocol   = "tcp"
    rule_no    = 89
    action     = "allow"
    cidr_block = "10.0.1.0/25"
    from_port  = "8080"
    to_port    = "8085"
  }
egress {
    protocol   = "tcp"
    rule_no    = 88
    action     = "allow"
    cidr_block = "10.0.0.0/25"
    from_port  = "22"
    to_port    = "22"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 87
    action     = "allow"
    cidr_block = "10.0.0.0/25"
    from_port  = "22"
    to_port    = "22"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 86
    action     = "allow"
    cidr_block = "10.0.1.0/25"
    from_port  = "22"
    to_port    = "22"
  }
  egress {
    protocol   = "tcp"
    rule_no    = 85
    action     = "allow"
    cidr_block = "10.0.1.0/25"
    from_port  = "22"
    to_port    = "22"    
  }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#   egress {
#     protocol   = "tcp"
#     rule_no    = 99
#     action     = "allow"
#     cidr_block = "10.0.26.0/23"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#     egress {
#     protocol   = "tcp"
#     rule_no    = 98
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "27017"
#     to_port    = "27017"
#   }
#     egress {
#     protocol   = "tcp"
#     rule_no    = 97
#     action     = "allow"
#     cidr_block = "10.0.26.0/23"
#     from_port  = "27017"
#     to_port    = "27017"
#   }
#    egress {
#     protocol   = "tcp"
#     rule_no    = 96
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#    egress {
#     protocol   = "tcp"
#     rule_no    = 95
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#      egress {
#     protocol   = "tcp"
#     rule_no    = 94
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#    egress {
#     protocol   = "tcp"
#     rule_no    = 93
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#        egress {
#     protocol   = "tcp"
#     rule_no    = 92
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "9200"
#     to_port    = "9200"
#   }
#    egress {
#     protocol   = "tcp"
#     rule_no    = 91
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "9200"
#     to_port    = "9200"
#   }

#   # --------------------------------------------
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 90
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 89
#     action     = "allow"
#     cidr_block = "10.0.26.0/23"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 88
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "27017"
#     to_port    = "27017"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 87
#     action     = "allow"
#     cidr_block = "10.0.26.0/23"
#     from_port  = "27017"
#     to_port    = "27017"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 86
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#    egress {
#     protocol   = "tcp"
#     rule_no    = 85
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 84
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 83
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 82
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "9200"
#     to_port    = "9200"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 81
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "9200"
#     to_port    = "9200"
#   }
# # ---------------------------------------------------

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 80
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 79
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "6379"
#     to_port    = "6379"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 78
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 77
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "9092"
#     to_port    = "9092"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 76
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "9200"
#     to_port    = "9200"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 75
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "9200"
#     to_port    = "9200"
#   }
#       ingress {
#     protocol   = "tcp"
#     rule_no    = 74
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 73
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "3306"
#     to_port    = "3306"
#   }
#     ingress {
#     protocol   = "tcp"
#     rule_no    = 72
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "27017"
#     to_port    = "27017"
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 71
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "27017"
#     to_port    = "27017"
#     }

# # -----------------------------------
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 70
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "22"
#     to_port    = "22"
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 69
#     action     = "allow"
#     cidr_block = "10.0.24.0/23"
#     from_port  = "22"
#     to_port    = "22"
#   }

# # -----------------------------------
# # -----------------------------------
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 68
#     action     = "allow"
#     cidr_block = "10.0.28.0/22"
#     from_port  = "22"
#     to_port    = "22"
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 67
#     action     = "allow"
#     cidr_block = "10.0.32.0/22"
#     from_port  = "22"
#     to_port    = "22"
#   }

# # -----------------------------------
# # -----------------------------------
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 66
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "22"
#     to_port    = "22"
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 65
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "22"
#     to_port    = "22"
#   }

# # -----------------------------------

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 64
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "22"
#     to_port    = "22"
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 63
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "22"
#     to_port    = "22"
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 62
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "8080"
#     to_port    = "8085"
#   }

#  egress {
#     protocol   = "tcp"
#     rule_no    = 61
#     action     = "allow"
#     cidr_block = "10.0.0.0/25"
#     from_port  = "8080"
#     to_port    = "8085"
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 60
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "8080"
#     to_port    = "8085"
#   }

#   egress {
#     protocol   = "tcp"
#     rule_no    = 59
#     action     = "allow"
#     cidr_block = "10.0.1.0/25"
#     from_port  = "8080"
#     to_port    = "8085"
#   }

  tags = {
    Name = "application_NACL"
    type = "application"
  }
}



/*==== NACL for database subnet ======*/
resource "aws_network_acl" "database" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.8.0/21"
    from_port  = "0"
    to_port    = "0"
  }
  egress {
    protocol   = "-1"
    rule_no    = 99
    action     = "allow"
    cidr_block = "10.0.16.0/21"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 98
    action     = "allow"
    cidr_block = "10.0.8.0/21"
    from_port  = "0"
    to_port    = "0"
  }
  ingress {
    protocol   = "-1"
    rule_no    = 97
    action     = "allow"
    cidr_block = "10.0.16.0/21"
    from_port  = "0"
    to_port    = "0"
  }  

  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 96
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "3306"
  #   to_port    = "3306"
  # }
  #   ingress {
  #   protocol   = "tcp"
  #   rule_no    = 95
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "3306"
  #   to_port    = "3306"
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 94
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "27017"
  #   to_port    = "27017"
  # }
  #   ingress {
  #   protocol   = "tcp"
  #   rule_no    = 93
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "27017"
  #   to_port    = "27017"
  # }

  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 92
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 91
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }

  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 90
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }
  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 89
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }

  

  tags = {
    Name = "database_NACL"
    type = "database"
  }
}

/*==== NACL for middleware subnet ======*/
resource "aws_network_acl" "middleware" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.8.0/21"
    from_port  = "0"
    to_port    = "0"
  }
    egress {
    protocol   = "-1"
    rule_no    = 99
    action     = "allow"
    cidr_block = "10.0.16.0/21"
    from_port  = "0"
    to_port    = "0"
  }
    ingress {
    protocol   = "-1"
    rule_no    = 98
    action     = "allow"
    cidr_block = "10.0.8.0/21"
    from_port  = "0"
    to_port    = "0"
  }
    ingress {
    protocol   = "-1"
    rule_no    = 97
    action     = "allow"
    cidr_block = "10.0.16.0/21"
    from_port  = "0"
    to_port    = "0"
  }
  #     egress {
  #   protocol   = "tcp"
  #   rule_no    = 96
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "9200"
  #   to_port    = "9200"
  # }
  #   egress {
  #   protocol   = "tcp"
  #   rule_no    = 95
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "9200"
  #   to_port    = "9200"
  # }

  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 94
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "6379"
  #   to_port    = "6379"
  # }
  #   ingress {
  #   protocol   = "tcp"
  #   rule_no    = 93
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "6379"
  #   to_port    = "6379"
  # }
  #   ingress {
  #   protocol   = "tcp"
  #   rule_no    = 92
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "9092"
  #   to_port    = "9092"
  # }
  #   ingress {
  #   protocol   = "tcp"
  #   rule_no    = 91
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "9092"
  #   to_port    = "9092"
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 90
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "9200"
  #   to_port    = "9200"
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 89
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "9200"
  #   to_port    = "9200"
  # }

  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 88
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 87
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }  

  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 86
  #   action     = "allow"
  #   cidr_block = "10.0.8.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }
  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 85
  #   action     = "allow"
  #   cidr_block = "10.0.16.0/21"
  #   from_port  = "22"
  #   to_port    = "22"
  # }    



  tags = {
    Name = "middleware_NACL"
    type = "middleware"
  }
}

/*==== NACL and subnet association ======*/
# resource "aws_network_acl_association" "application_NACL" {
#   network_acl_id = aws_network_acl.application.id
#   count          = "${length(var.private_application_subnets_cidr)}"
#   subnet_id      = "${element(aws_subnet.private_application_subnet.*.id, count.index)}"
# }

# resource "aws_network_acl_association" "database_NACL" {
#   network_acl_id = aws_network_acl.database.id
#   count          = "${length(var.private_database_subnets_cidr)}"
#   subnet_id      = "${element(aws_subnet.private_database_subnet.*.id, count.index)}"
# }

# resource "aws_network_acl_association" "middleware_NACL" {
#   network_acl_id = aws_network_acl.middleware.id
#   count          = "${length(var.private_middleware_subnets_cidr)}"
#   subnet_id      = "${element(aws_subnet.private_middleware_subnet.*.id, count.index)}"
# }



