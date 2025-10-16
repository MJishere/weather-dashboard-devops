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
# Mount EBS volume
# -------------------------------------------
if ! blkid /dev/xvdf; then
    mkfs -t ext4 /dev/xvdf
fi

mkdir -p /var/jenkins_home
mount /dev/xvdf /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home


# ---------------------------
# Install Git (needed for Jenkins pipelines)
# ---------------------------
yum install -y git


# ---------------------------
# Install Terraform (HashiCorp repo for Amazon Linux)
# ---------------------------
dnf install -y dnf-plugins-core || true
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo || true
dnf -y install terraform || true


# ---------------------------
# Install kubectl (official Kubernetes method with SHA verification)
# ---------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client || true


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
