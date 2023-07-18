terraform {
  required_providers {
    aws = {
      version = "~> 5.5.0"
    }
  }

  # 0.12.29 버전 이상을 의미
  required_version = "~> 1.5.1"
}

provider "aws" {
  region = "ap-northeast-2"
}