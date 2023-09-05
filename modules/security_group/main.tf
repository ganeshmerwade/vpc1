resource "aws_security_group" "public_SG" {
  name = "public_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow SSH"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "Allow HTTPS"
    from_port        = "443"
    to_port          = "443"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # ingress {
  #   description      = "Allow redis"
  #   from_port        = "6379"
  #   to_port          = "6379"
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description      = "Allow kafka"
  #   from_port        = "9092"
  #   to_port          = "9092"
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description      = "Allow ES"
  #   from_port        = "9200"
  #   to_port          = "9200"
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description      = "Allow mysql"
  #   from_port        = "3306"
  #   to_port          = "3306"
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description      = "Allow mongodb"
  #   from_port        = "27017"
  #   to_port          = "27017"
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_SG"
  }
}

resource "aws_security_group" "application_SG" {
  name = "application_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow SSH"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.public_SG.id}"]
  }

  ingress {
    description      = "Allow traffic"
    from_port        = "8080"
    to_port          = "8085"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.public_SG.id}"]
  }

  # ingress {
  #   description      = "Allow redis"
  #   from_port        = "6379"
  #   to_port          = "6379"
  #   protocol         = "tcp"
  #   security_groups  = ["${aws_security_group.public_SG.id}"]
  # }
  # ingress {
  #   description      = "Allow kafka"
  #   from_port        = "9092"
  #   to_port          = "9092"
  #   protocol         = "tcp"
  #   security_groups  = ["${aws_security_group.public_SG.id}"]
  # }
  # ingress {
  #   description      = "Allow ES"
  #   from_port        = "9200"
  #   to_port          = "9200"
  #   protocol         = "tcp"
  #   security_groups  = ["${aws_security_group.public_SG.id}"]
  # }
  # ingress {
  #   description      = "Allow mysql"
  #   from_port        = "3306"
  #   to_port          = "3306"
  #   protocol         = "tcp"
  #   security_groups  = ["${aws_security_group.public_SG.id}"]
  # }
  # ingress {
  #   description      = "Allow mongodb"
  #   from_port        = "27017"
  #   to_port          = "27017"
  #   protocol         = "tcp"
  #   security_groups  = ["${aws_security_group.public_SG.id}"]
  # }

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application_SG"
  }
}

resource "aws_security_group" "database_SG" {
  name = "database_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow traffic"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }

  ingress {
    description      = "Allow mysql"
    from_port        = "3306"
    to_port          = "3306"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }
  ingress {
    description      = "Allow mongodb"
    from_port        = "27017"
    to_port          = "27017"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_SG"
  }
}

resource "aws_security_group" "middleware_SG" {
  name = "middleware_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow traffic"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }

  ingress {
    description      = "Allow redis"
    from_port        = "6379"
    to_port          = "6379"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }
  ingress {
    description      = "Allow kafka"
    from_port        = "9092"
    to_port          = "9092"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }
  ingress {
    description      = "Allow ES"
    from_port        = "9200"
    to_port          = "9200"
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.application_SG.id}"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "middleware_SG"
  }
}

/*resource "aws_security_group" "mysqlclient_SG" {
  name = "mysqlclient_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow mysql"
    from_port        = "3306"
    to_port          = "3306"
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/25","10.0.1.0/25","10.0.24.0/23","10.0.26.0/23"]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ESclient_SG"
  }
}

resource "aws_security_group" "mongodbclient_SG" {
  name = "mongodbclient_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow mongodb"
    from_port        = "27017"
    to_port          = "27017"
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/25","10.0.1.0/25","10.0.24.0/23","10.0.26.0/23"]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongodbclient_SG"
  }
}

resource "aws_security_group" "ESmongodb_SG" {
  name = "ESmongodb_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow ES"
    from_port        = "9200"
    to_port          = "9200"
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/25","10.0.1.0/25","10.0.28.0/22","10.0.32.0/22"]
  }
   ingress {
    description      = "Allow mongodb"
    from_port        = "27107"
    to_port          = "27107"
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/25","10.0.1.0/25","10.0.24.0/23","10.0.26.0/23"]
  }
  
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ESmongodb_SG"
  }
}*/

