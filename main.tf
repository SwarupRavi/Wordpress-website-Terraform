provider "aws" {
   region = "us-east-1"
  access_key = "AKIASMTPC6PQJPBLZLMF"
  secret_key = "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" 
}
 terraform {
 required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
 }
 }
 resource "aws_vpc" "myvpc" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   tags={
     Name="sjsjsn-vpc"
   }
   
 }
 resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "192.168.0.0/24"
  tags = {
      Name="subnet-1"
  }
}
resource "aws_subnet" "subnet2"{
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "192.168.1.0/24"
    tags = {
      Name = "subnet-2"
    }
}

 
#creating a internet gateway(router ) and attaching it to the vpc created (allows resources in the subnets to connect to internet)
 resource "aws_internet_gateway" "gw1" {
    vpc_id=aws_vpc.myvpc.id
    
    tags ={
        Name="My-router"
    }
}
#creating a routing table so that it will allow the internet gateway connect the vpcs to the internet 
resource "aws_route_table" "r" {
    vpc_id =aws_vpc.myvpc.id
    route{
        cidr_block ="0.0.0.0/0"    
        gateway_id = aws_internet_gateway.gw1.id
    }
    tags={
            Name="My-routing-table"
}
}

// creating an routing table  association

resource "aws_route_table_association" "a"{
    subnet_id =aws_subnet.subnet1.id
    route_table_id = aws_route_table.r.id

} 
#Creating the Security Group for the WordPress and MySQL.
#wordpress in subnet 1 and mysql in subnet 2 because subnet 2 has no internet connection
//Creating Security-Group for Word-Press. port 80 (HTTP) for clients, and port 22 (SSH)
resource "aws_security_group" "SG1" {
  name        = "Word-Press-SG"
  description = "Allow SSH,HTTP"
  vpc_id      = aws_vpc.myvpc.id


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "My-SecGrp"
  }
}
#for mysql security group
//Creating Security-Group for MySQL allowing port 3306
resource "aws_security_group" "SG2" {
  name        = "MySQL-SG"
  description = "Allow port 3306"
  vpc_id      = aws_vpc.myvpc.id


  ingress {
    description = "MySQL-port"
    from_port   = 3306
    to_port     = 3306
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
    Name = "MySQL-SecGrp"
  }
}

 #launching an instance which has mysql setup
#Launching an Instance which has WordPress already setup. 
resource aws_instance "myint" {
  ami           = "ami-0a1a029889611aba7"
  instance_type = "t2.micro"
  key_name      = "key4"
  associate_public_ip_address = true
  security_groups = [ "${aws_security_group.SG2.id}"]
  subnet_id = aws_subnet.subnet2.id

  


  tags = {
    Name = "MySQL-OS"
  }
}
#Launching an Instance which has WordPress already setup. 
resource aws_instance "myint1" {
  ami           = "ami-0f00da835c2459ec4"
  instance_type = "t2.micro"
  key_name      = "key4"
  associate_public_ip_address=true
  security_groups = [ "${aws_security_group.SG1.id}"]
  subnet_id = aws_subnet.subnet1.id
  

  tags = {
    Name = "WordPress-OS"

  }
}



   