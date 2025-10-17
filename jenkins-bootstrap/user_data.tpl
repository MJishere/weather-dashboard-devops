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
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# -------------------------------------------
# Ensure Docker container restarts on reboot
# -------------------------------------------
docker update --restart=always jenkins

# -------------------------------------------
# Add host Docker GID inside container for Jenkins user
# -------------------------------------------
HOST_DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
docker exec -u root jenkins bash -c "groupadd -g $HOST_DOCKER_GID dockerhost || true && usermod -aG $HOST_DOCKER_GID jenkins || true"

# -------------------------------------------
# Install Terraform + kubectl inside Jenkins container
# -------------------------------------------

# Wait for Jenkins container to fully start
sleep 20

# -------------------------------------------
# Install Terraform + kubectl + Git + AWS CLI inside Jenkins container
# -------------------------------------------
docker exec -u 0 jenkins bash -c "
  # Update package lists inside container
  apt-get update &&

  # Install Docker CLI only (no daemon), needed for Jenkins to run docker commands via host socket
  apt-get install -y docker-cli &&

  # Install supporting tools for downloads, unzipping, and scripting
  apt-get install -y gnupg curl wget unzip git bash &&

  # -------------------------------------------
  # Install AWS CLI v2 inside container
  # -------------------------------------------
  curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" &&
  unzip awscliv2.zip &&
  ./aws/install &&
  rm -rf awscliv2.zip aws &&

  # -------------------------------------------
  # Install Terraform
  # -------------------------------------------
  # Add HashiCorp GPG key
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg &&
  # Add HashiCorp apt repository
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com trixie main' > /etc/apt/sources.list.d/hashicorp.list &&
  # Update package lists after adding new repo
  apt-get update &&
  # Install Terraform
  apt-get install -y terraform &&
  # Verify installation
  terraform -version &&

  # -------------------------------------------
  # Install kubectl
  # -------------------------------------------
  # Download latest stable release of kubectl
  curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl &&
  # Move kubectl to /usr/local/bin and set proper permissions
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
  # Verify kubectl installation
  kubectl version --client
"