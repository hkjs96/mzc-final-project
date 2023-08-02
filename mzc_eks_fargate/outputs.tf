output "private_subnet_2a_id" {
  value = data.aws_subnet.eks-pvt_2a.id
  description = "The id of the private subent a"
}

output "private_subnet_2c_id" {
  value = data.aws_subnet.eks-pvt_2c.id
  description = "The id of the private subent c"
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks-cluster.name
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "identity" {
  description = "AWS region"
  value       = aws_eks_cluster.eks-cluster.identity
}