output "order-sqs-name" {
  value = aws_sqs_queue.lambda_queue.name
}

output "order-sqs-arn" {
  value = aws_sqs_queue.lambda_queue.arn
}

output "order-sqs-id" {
  value = aws_sqs_queue.lambda_queue.id
}

output "order-sqs-tags_all" {
  value = aws_sqs_queue.lambda_queue.tags_all
}

output "order-dead_letter_queue-name" {
  value = aws_sqs_queue.dead_letter_queue.name
}

output "order-dead_letter_queue-arn" {
  value = aws_sqs_queue.dead_letter_queue.arn
}

output "order-dead_letter_queue-id" {
  value = aws_sqs_queue.dead_letter_queue.id
}

output "order-dead_letter_queue-tags_all" {
  value = aws_sqs_queue.dead_letter_queue.tags_all
}