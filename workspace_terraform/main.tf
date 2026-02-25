provider "aws"{
    region = "us-east-1"
}

variable "instance_type"{
    description = "EC2 instance type"
    type = map(string)

    default = {
        "dev" = "t3.micro"
        "prod" = "t3.small"
    }
}

variable "ami_id"{
    description = "EC2 instance type"
    type = map(string)

    default = {
        "dev" = "ami-0f3caa1cf4417e51b"
        "prod" = "ami-0f3caa1cf4417e51b"
    }
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
    ami = lookup(var.ami_id, terraform.workspace, "ami-0f3caa1cf4417e51b")
    instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
    subnet_id = aws_subnet.development_subnet_public.id
    security_groups = [aws_security_group.dev_allow_ssh.id]
    associate_public_ip_address = true
    tags = {
        Name = "Public Development server"
    }
}

output "dev_server_public_ip"{
    value = aws_instance.public_dev_server.public_ip
}
