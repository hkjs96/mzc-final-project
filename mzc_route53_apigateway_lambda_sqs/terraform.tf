terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5"        # ~> 5.5 : 5.5 이상인 모든 5.x 버전 적용
    }
  }

  required_version = ">= 1.5.0" # >= 1.2.0 : 1.2.0 아상인 모든 버전
}

provider "aws" {
  region  = "ap-northeast-2"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}