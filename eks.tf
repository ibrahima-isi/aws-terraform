# Cluster EKS
resource "aws_eks_cluster" "terraform_cluster" {
  name     = "terraform-eks-cluster"
  version  = "1.27"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id
    ]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Groupe de noeuds EKS
resource "aws_eks_node_group" "terraform_cluster_node_group" {
  cluster_name    = aws_eks_cluster.terraform_cluster.name
  node_group_name = "terraform-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]
}

# Rôle IAM pour le cluster EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "terraform-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Rôle IAM pour les noeuds EKS
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Add-ons EKS
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.terraform_cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.terraform_cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.terraform_cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.terraform_cluster.name
  addon_name   = "aws-ebs-csi-driver"
}