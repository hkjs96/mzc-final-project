output "region" {
  description = "AWS region"
  value       = var.region
}

output "dynamodb_name" {
  description = "dynamodb table name"
  value = aws_dynamodb_table.order-history-dynamodb-table.name
}

output "dynamodb_arn" {
  description = "dynamodb table arn"
  value = aws_dynamodb_table.order-history-dynamodb-table.arn
}

output "dynamodb_tags" {
  description = "dynamodb table tags"
  value = aws_dynamodb_table.order-history-dynamodb-table.tags_all
}