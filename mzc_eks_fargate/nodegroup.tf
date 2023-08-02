resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids = [
    data.aws_subnet.eks-pub_2a.id,
    data.aws_subnet.eks-pub_2c.id,
  ] 

  # Optional Property, t3.small - 11 pod 
  instance_types = [ "t2.micro" ]

  scaling_config {
    desired_size = 5
    max_size     = 15
    min_size     = 5
  }

  update_config {
    max_unavailable = 1
  }

  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-AWSXRayDaemonWriteAccess,
  ]
}

### Node Group IAM ###

data "aws_iam_policy_document" "nodegroup-assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-node-group-role" {
  name               = "eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.nodegroup-assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-role.name
}


# X-Ray 사용을 위한 정책 추가
resource "aws_iam_role_policy_attachment" "eks-AWSXRayDaemonWriteAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.eks-node-group-role.name
}