resource "aws_eks_fargate_profile" "cert-manager" {
  cluster_name           = aws_eks_cluster.eks-cluster.name
  fargate_profile_name   = "cert-manager"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn
  subnet_ids             = [
    data.aws_subnet.eks-pvt_2a.id,
    data.aws_subnet.eks-pvt_2c.id,
  ]

  selector {
    namespace = "cert-manager"
  }
  tags = {
    Name = "cert-manager"
  }
}


resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = aws_eks_cluster.eks-cluster.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn
  subnet_ids             = [
    data.aws_subnet.eks-pvt_2a.id,
    data.aws_subnet.eks-pvt_2c.id,
  ]

  selector {
    namespace = "kube-system"
  }
  tags = {
    Name = "kube-system"
  }
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.eks-cluster.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn
  subnet_ids             = [
    data.aws_subnet.eks-pvt_2a.id,
    data.aws_subnet.eks-pvt_2c.id,
  ]

  selector {
    namespace = "default"
  }
  tags = {
    Name = "default"
  }
}

resource "aws_iam_role" "eks-fargate-profile" {
  name = "mzc-eks-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile.name
}