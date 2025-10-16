#!/bin/bash
# -------------------------------------------
# Update system packages
# -------------------------------------------
yum update -y

# -------------------------------------------
# Install Docker
# -------------------------------------------
amazon-linux-extras enable docker
yum install -y docker

# -------------------------------------------
# Start Docker service
# -------------------------------------------
systemctl start docker
systemctl enable docker

# -------------------------------------------
# Add ec2-user to docker group
# -------------------------------------------
usermod -aG docker ec2-user

# -------------------------------------------
# Mount EBS volume for Jenkins
# -------------------------------------------
if ! blkid /dev/xvdf; then
    mkfs -t ext4 /dev/xvdf
fi

mkdir -p /var/jenkins_home
mount /dev/xvdf /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home

# -------------------------------------------
# Install Git (needed for Jenkins pipelines)
# -------------------------------------------
yum install -y git

# -------------------------------------------
# Run Jenkins container
# -------------------------------------------
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# -------------------------------------------
# Ensure Docker container restarts on reboot
# -------------------------------------------
docker update --restart=always jenkins

# -------------------------------------------
# Install Terraform + kubectl inside Jenkins container
# -------------------------------------------

# Wait for Jenkins container to fully start
sleep 20

# -------------------------------------------
# Install Terraform + kubectl inside Jenkins container
# -------------------------------------------
docker exec -u 0 jenkins bash -c "
  apt-get update &&
  apt-get install -y gnupg curl wget unzip git bash &&
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg &&
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com trixie main' > /etc/apt/sources.list.d/hashicorp.list &&
  apt-get update &&
  apt-get install -y terraform &&
  terraform -version &&
  # Install kubectl
  curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl &&
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
  kubectl version --client
"