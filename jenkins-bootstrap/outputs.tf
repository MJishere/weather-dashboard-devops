output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins.id
}

output "jenkins_security_group_id" {
  value = aws_security_group.jenkins_sg.id
}
