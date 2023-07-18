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
