#Create a vpc to define your data center inside aws platform 
resource "aws_vpc" "vpc" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Project"
  }
}

#Create a subnet inside vpc
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub_Pub1"
  }
}


resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sub_Priv1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub_Pub2"
  }
}


resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.2.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "sub_Priv2"
  }
}

resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.5.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub_Pub3"
  }
}

resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.2.6.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "sub_Priv3"
  }
}

#Create a route table inside the custom vpc
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_pub"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.pub.id
}

#Create internet gateway inside the vpc
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igateway_pub"
  }
}

#Create a security group for this vpc
resource "aws_security_group" "traffic_allowed" {
  name        = "traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pub_SG"
  }
}

#Launch instance to the vpc defined 
resource "aws_instance"  "server1" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  key_name                    = "teraKey"
  subnet_id                   = aws_subnet.public1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.traffic_allowed.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.server1.public_ip
    private_key = file(var.key_name)
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.server1.public_ip} >> inventory-host"
}
 
  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${var.key_name} httpd.yml"
}
  tags = {
    Name = "server1"
  }
}

resource "aws_instance" "server2" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1b"
  key_name                    = "teraKey"
  subnet_id                   = aws_subnet.public2.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.traffic_allowed.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file(var.key_name)
} 
   provisioner "local-exec" {
    command = "echo ${aws_instance.server2.public_ip} >> inventory-host"
}

  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${var.key_name} httpd.yml"
} 

  tags = {
    Name = "server2"
  }
}

resource "aws_instance" "server3" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1c"
  key_name                    = "teraKey"
  subnet_id                   = aws_subnet.public3.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.traffic_allowed.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.server3.public_ip
    private_key = file(var.key_name)
  }
 
   provisioner "local-exec" {
    command = "echo ${aws_instance.server3.public_ip} >> inventory-host"
}

 provisioner "local-exec" {
    command = "ansible-playbook --private-key ${var.key_name} httpd.yml"
}  

  tags = {
    Name = "server3"
  }
}


