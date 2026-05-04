provider "aws" {
    region = var.region
  
}

resource "aws_security_group" "Multi_Env_pipeline" {
    name = "MultiEnvSecurity"
    description = "All port to allow traffic"

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Custom"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "out traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}


resource "aws_instance" "Multi_Env_instance" {
    instance_type = var.instance_type
    ami = var.ami
    key_name = "Devops-project-1"
    vpc_security_group_ids = [aws_security_group.Multi_Env_pipeline.id]

    user_data = file("${path.module}/All_packages.sh")

    tags = {
        Name = "Multi-infra-pipeline-3"
    }
  
}