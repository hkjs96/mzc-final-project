variable "lambda_function_name" {
  default = "lambda_function_name"
}

variable "owner" {
  default = "116643118394"
}

variable "order_sqs_name" {
  default = "order_queue"
}

variable "order_dead_letter_queue_name" {
  default = "order_queue-deadletter-queue"
}

variable "domain_name" {
  default = "mega-mall.site"
}

variable "table_name" {
  default = "OrderHistory"
}
