variable "instance_type"{
    description = "EC2 instance type"
    type = string
}

variable "ami_id"{
    description = "EC2 instance type"
    type = string
}

provider "aws"{
    region = "us-east-1"
}

resource "aws_vpc" "development_vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "DevelopmentVpc"
    }
}

resource "aws_subnet" "development_subnet_public"{
    vpc_id = aws_vpc.development_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Development Public Subnet"
    }
}

resource "aws_subnet" "development_subnet_private"{
    vpc_id = aws_vpc.development_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Development Private Subnet"
    }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.development_vpc.id
  tags = {
    Name = "Development IGW"
  }
}

resource "aws_route_table" "dev_route_table"{
    vpc_id = aws_vpc.development_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev_igw.id
    }
    tags = {
        Name = "Development Route Table"
    }
}

resource "aws_route_table_association" "dev_rt_association"{
    subnet_id = aws_subnet.development_subnet_public.id
    route_table_id = aws_route_table.dev_route_table.id
}

resource "aws_security_group" "dev_allow_ssh"{
    name = "allow dev ssh"
    description = "Allow ssh inbound traffic"
    vpc_id = aws_vpc.development_vpc.id

    ingress {
        description = "SSH from Internent"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "public_dev_server"{
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.development_subnet_public.id
    security_groups = [aws_security_group.dev_allow_ssh.id]
    associate_public_ip_address = true
    tags = {
        Name = "Public Development server"
    }
}

resource "aws_instance" "private_dev_server"{
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.development_subnet_private.id
    security_groups = [aws_security_group.dev_allow_ssh.id]
    tags = {
        Name = "Private Development Server"
    }
}

output "dev_server_public_ip"{
    value = aws_instance.public_dev_server.public_ip
}