variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "project_name" {
  type        = string
  default     = "weather_dashboard"
  description = "Project Name"
}

variable "jenkins_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Jenkins instance type"
}

variable "jenkins_sg_name" {
  type    = string
  default = "jenkins-sg"
}

variable "jenkins_volume_size" {
  type    = number
  default = 20
}

variable "jenkins_ami" {
  type    = string
  default = "ami-052064a798f08f0d3" # Amazon Linux
}