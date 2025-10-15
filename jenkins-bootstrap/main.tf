
# Use Default VPC to pick a public subnet

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  jenkins_subnet_id = data.aws_subnets.public_subnets.ids[0]
}

# Fetch subnet details to get the AZ
data "aws_subnet" "jenkins_subnet" {
  id = local.jenkins_subnet_id
}

# IAM role for Jenkins EC2 instance.

resource "aws_iam_role" "jenkins_ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_ec2_policy" {
  name = "jenkins-ec2-policy"
  role = aws_iam_role.jenkins_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "eks:*",
          "ecr:*",
          "s3:*",
          "dynamodb:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}


# Security group for Jenkins

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow HTTP (8080) and SSH (22) to Jenkins"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}


#EBS persistant volume for jenkins

resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = data.aws_subnet.jenkins_subnet.availability_zone
  size              = var.jenkins_volume_size
  type              = "gp3"

  tags = {
    Name = "jenkins-data"
  }
}


resource "aws_instance" "jenkins" {
  ami                         = var.jenkins_ami
  instance_type               = var.jenkins_instance_type
  subnet_id                   = local.jenkins_subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_instance_profile.name
  user_data                   = templatefile("${path.module}/user_data.tpl", { volume_id = aws_ebs_volume.jenkins_volume.id })
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_volume_attachment" "jenkins_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.jenkins_volume.id
  instance_id = aws_instance.jenkins.id
}