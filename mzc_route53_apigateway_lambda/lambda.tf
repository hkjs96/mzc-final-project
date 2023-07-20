# 이 역할이 수행할 수 있는 작업이 아니라 누가 이 역할을 맡을 수 있는지에 대한 정책을 정의
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "dynamodb_policy_one" {
  name        = "dynamodb_policy_one"
  path        = "/"
  description = "dynamodb_policy_one"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:*:*"
      },
    ]
  })

  tags = {
    Name: "dynamodb_policy_one"
  }
}

resource "aws_iam_policy" "dynamodb_policy_two" {
  name        = "dynamodb_policy_two"
  path        = "/"
  description = "dynamodb_policy_two"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetRecords",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:*:*"
      },
    ]
  })

  tags = {
    Name: "dynamodb_policy_two"
  }
}

resource "aws_iam_policy" "sqs_policy" {
  name        = "sqs_policy"
  path        = "/"
  description = "sqs_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:sqs:*:*:*"
      },
    ]
  })

  tags = {
    Name: "sqs_policy"
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "cloudwatch_logs_policy"
  # path -  IAM 정책을 정의하는 데 사용되는 것이 아니며, 사용자 및 그룹을 고유한 네임스페이스로 그룹화하는 데 사용
  path        = "/"
  description = "cloudwatch_logs_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })

  tags = {
    Name: "cloudwatch_logs_policy"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_one" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamodb_policy_one.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_two" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamodb_policy_two.arn
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}


data "archive_file" "orderConsumer" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "lambda_payload.zip"
}

resource "aws_lambda_function" "orderConsumer" {
  filename      = "lambda_payload.zip"
  function_name = "orderConsumer"
  role          = aws_iam_role.iam_for_lambda.arn

  handler       = "orderConsumer.handler"

  source_code_hash = data.archive_file.orderConsumer.output_base64sha256

  runtime = "nodejs18.x"

  depends_on = [ 
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_one,
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_two,
    aws_iam_role_policy_attachment.lambda_sqs,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.order_consumer_lambda_log_group,
  ]

  tags = {
    Name: "orderConsumerHandler"
  }

  environment {
    variables = {
      OWNER = "756852414300"
      QUEUE_NAME = "order_queue"
      TABLE_NAME = "OrderHistory"
    }
  }
} 

data "archive_file" "order" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "lambda_payload.zip"
}

resource "aws_lambda_function" "order" {
  filename      = "lambda_payload.zip"
  function_name = "order"
  role          = aws_iam_role.iam_for_lambda.arn

  handler       = "order.handler"

  source_code_hash = data.archive_file.order.output_base64sha256

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  runtime = "nodejs18.x"

  depends_on = [ 
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_one,
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_two,
    aws_iam_role_policy_attachment.lambda_sqs,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.order_lambda_log_group,
  ]

  tags = {
    Name: "orderHandler"
  }

  environment {
    variables = {
      OWNER = "756852414300"
      QUEUE_NAME = "order_queue"
      TABLE_NAME = "OrderHistory"
    }
  }
}

/*
  cloudwatch
*/    

resource "aws_cloudwatch_log_group" "order_lambda_log_group" {
  name              = "/aws/lambda/order"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "order_consumer_lambda_log_group" {
  name              = "/aws/lambda/orderConsumer"
  retention_in_days = 14
}

/*
resource "aws_lambda_layer_version" "example" {
  # ... other configuration ...
}

resource "aws_lambda_function" "example" {
  # ... other configuration ...
  layers = [aws_lambda_layer_version.example.arn]
}
*/

/*
  zip -r <ZIP_FILE>.zip <아카이브대상경로>
*/

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "./lambda_layer"
  output_path = "lambda_layer_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "lambda_layer_payload.zip"
  layer_name = "lambda_layer_name"

  compatible_runtimes = ["nodejs18.x"]
}