# IAM Role for EKS Cluster

resource "aws_iam_role" "eks_cluster_role"{
    name = "${var.project_name}_eks_cluster_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = { Service = "eks.amazonaws.com"}
        }]
    })

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy"{
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_controller"{
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create EKS Cluster

resource "aws_eks_cluster" "eks_cluster"{
    name = "${var.project_name}_eks"
    version = "1.34"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config{
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = true
        endpoint_public_access  = true
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_controller
    ]
}

# IAM Role for Worker Nodes

resource "aws_iam_role" "eks_node_role"{
    name = "${var.project_name}_eks_node_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Service = "ec2.amazonaws.com"}
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "Worker_node_AmazonEKSWorkerNodePolicy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "Worker_node_AmazonEKS_CNI_Policy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "Worker_node_AmazonEC2ContainerRegistryReadOnly"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_node_role.name
}

# Node Group creation

resource "aws_eks_node_group" "eks_node_group"{
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "${var.project_name}_node_group"
    node_role_arn = aws_iam_role.eks_node_role.arn
    subnet_ids = var.private_subnet_ids

    scaling_config {
        desired_size = 1
        max_size = 2
        min_size = 1
    }

    instance_types = ["t3.medium"]
}