### EKS ###

/*
  1. 클러스터를 구성하는 서브넷에 태그 여부 확인하기
    kubernetes.io/cluster/클러스터_이름 = "shared/owned" 
  2. 프라이빗 서브넷이 존재하는 라우팅 테이블에 NAT 리소스가 존재하는지 확인
*/
resource "aws_eks_cluster" "eks-cluster" {
  name     = "fargate-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.eks-pub_2a.id,
      data.aws_subnet.eks-pub_2c.id,
      data.aws_subnet.eks-pub_2b.id,
      data.aws_subnet.eks-pub_2d.id,
      data.aws_subnet.eks-pvt_2a.id,
      data.aws_subnet.eks-pvt_2c.id,
    ]  # Replace with your desired subnet IDs
  }

  # Amazon EKS 컨트롤 플레인 로깅 (옵션)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    data.aws_subnet.eks-pub_2a,
    data.aws_subnet.eks-pub_2c,
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]

  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled" = true,
    "Name" = "EKS-FARGATE"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-cluster-role" {
  name               = "mzc-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}

### EKS END ###


