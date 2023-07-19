resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids = [
    data.aws_subnet.eks-pvt_2a.id,
    data.aws_subnet.eks-pvt_2c.id,
  ] 

  # Optional Property
  instance_types = [ "t3.large" ]

  scaling_config {
    desired_size = 6
    max_size     = 8
    min_size     = 4
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




