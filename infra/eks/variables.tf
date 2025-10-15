
variable "project_name" {
  type        = string
  description = "Project name for tagging resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for worker nodes"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs (for EKS endpoint access / ALB)"
}
