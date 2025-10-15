output "eks_cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "EKS API endpoint"
}

output "eks_node_group_name" {
  value       = aws_eks_node_group.eks_node_group.node_group_name
  description = "Node group name"
}
