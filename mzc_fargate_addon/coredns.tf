data "aws_eks_cluster" "eks-cluster" {
  name = "eks-cluster"
}


resource "aws_eks_addon" "coredns" {
  cluster_name                = data.aws_eks_cluster.eks-cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.1" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on                  = [data.aws_eks_cluster.eks-cluster]
}