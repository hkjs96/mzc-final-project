data "aws_subnet" "eks-pvt_2a" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pvt_2a"]
  }
}

data "aws_subnet" "eks-pvt_2c" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pvt_2c"]
  }
}