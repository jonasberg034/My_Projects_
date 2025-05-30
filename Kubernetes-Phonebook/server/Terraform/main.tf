provider "aws" {
  region  = var.region
  profile = "profile-jonas"

}

data "aws_vpc" "name" {
  default = true
}

resource "aws_security_group" "petclinic_mutual_sg" {
  name = var.sec_gr_mutual
  vpc_id = data.aws_vpc.name.id

  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10250
    self = true
  }

    ingress {
    protocol = "udp"
    from_port = 8472
    to_port = 8472
    self = true
  }

    ingress {
    protocol = "tcp"
    from_port = 2379
    to_port = 2380
    self = true
  }

}

resource "aws_security_group" "petclinic_kube_worker_sg" {
  name = var.sec_gr_k8s_worker
  vpc_id = data.aws_vpc.name.id


  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kube-worker-secgroup"
  }
}

resource "aws_security_group" "petclinic_kube_master_sg" {
  name = var.sec_gr_k8s_master
  vpc_id = data.aws_vpc.name.id

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 10257
    to_port = 10257
    self = true
  }

  ingress {
    protocol = "tcp"
    from_port = 10259
    to_port = 10259
    self = true
  }

  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "kube_master_secgroup"
  }
}

resource "aws_iam_role" "petclinic_master_server_s3_role" {
  name               = "petclinic_master_server_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.petclinic_master_server_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "petclinic_master_server_profile2" {
  name = "petclinic_master_server_profile2"
  role = aws_iam_role.petclinic_master_server_s3_role.name
}

resource "aws_instance" "kube-master" {
    ami = var.ami_id
    instance_type = var.instance_type
    iam_instance_profile = aws_iam_instance_profile.petclinic_master_server_profile2.name
    vpc_security_group_ids = [aws_security_group.petclinic_kube_master_sg.id, aws_security_group.petclinic_mutual_sg.id]
    key_name = var.key_name
    subnet_id = var.subnet_id  # select own subnet_id of us-east-1a
    availability_zone = var.availability_zone
    tags = {
        Name = "kube-master"
        Project = "tera-kube-ans"
        Role = "master"
        Id = "1"
        environment = "dev"
    }
}

resource "aws_instance" "worker-1" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.petclinic_kube_worker_sg.id, aws_security_group.petclinic_mutual_sg.id]
    key_name = var.key_name
    subnet_id = var.subnet_id   # select own subnet_id of us-east-1a
    availability_zone = var.availability_zone
    tags = {
        Name = "worker-1"
        Project = "tera-kube-ans"
        Role = "worker"
        Id = "1"
        environment = "dev"
    }
}

resource "aws_instance" "worker-2" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.petclinic_kube_worker_sg.id, aws_security_group.petclinic_mutual_sg.id]
    key_name = var.key_name
     subnet_id = var.subnet_id   # select own subnet_id of us-east-1a
    availability_zone = var.availability_zone
    tags = {
        Name = "worker-2"
        Project = "tera-kube-ans"
        Role = "worker"
        Id = "2"
        environment = "dev"
    }
}

output kube-master-ip {
  value       = aws_instance.kube-master.public_ip
  sensitive   = false
  description = "public ip of the kube-master"
}

output worker-1-ip {
  value       = aws_instance.worker-1.public_ip
  sensitive   = false
  description = "public ip of the worker-1"
}

output worker-2-ip {
  value       = aws_instance.worker-2.public_ip
  sensitive   = false
  description = "public ip of the worker-2"
}