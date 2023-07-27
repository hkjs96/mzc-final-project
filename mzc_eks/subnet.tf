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

data "aws_subnet" "eks-pvt_2b" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pvt_2b"]
  }
}

data "aws_subnet" "eks-pvt_2d" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pvt_2d"]
  }
}

### public

data "aws_subnet" "eks-pub_2a" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pub_2a"]
  }
}

data "aws_subnet" "eks-pub_2b" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pub_2b"]
  }
}

data "aws_subnet" "eks-pub_2c" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pub_2c"]
  }
}

data "aws_subnet" "eks-pub_2d" {
  filter {
    name   = "tag:Name"
    values = ["ap-northeast-2-pub_2d"]
  }
}