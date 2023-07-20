resource "aws_sqs_queue" "lambda_queue" {
  name                      = var.order_sqs_name
  message_retention_seconds = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 4
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.dead_letter_queue.arn]
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = var.order_sqs_name
  message_retention_seconds = 86400
  
}


resource "aws_lambda_event_source_mapping" "lambda_via_sqs" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.lambda_queue.arn
  function_name    = aws_lambda_function.orderConsumer.function_name

  depends_on = [
    aws_lambda_function.orderConsumer
  ]
}
