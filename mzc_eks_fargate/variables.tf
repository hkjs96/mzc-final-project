variable "security_group_name" {
  description = "The name of the security group for VPC"
  type        = string
  default     = "test-sg"
}

variable "http_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "ssh_port" {
  description = "The port the server will use for SSH requests"
  type        = number
  default     = 22
}

/*
  Route 53 - 도메인 관련
*/
variable "route53_zone_id" {
  description = "The zone id of route53 "
  type        = string
  default     = "Z06535841T3IN9MV0MLS0"
}



/*
  리전
*/
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}