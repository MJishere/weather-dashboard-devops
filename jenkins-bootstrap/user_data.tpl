#!/bin/bash
# Update system packages
yum update -y

# Install Docker
amazon-linux-extras enable docker
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Mount EBS volume
if ! blkid /dev/xvdf; then
    mkfs -t ext4 /dev/xvdf
fi

mkdir -p /var/jenkins_home
mount /dev/xvdf /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home

# Run Jenkins container
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Ensure Docker container restarts on reboot
docker update --restart=always jenkins
