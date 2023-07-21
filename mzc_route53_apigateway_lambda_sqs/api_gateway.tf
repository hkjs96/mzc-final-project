resource "aws_api_gateway_rest_api" "order_api" {
  name        = "order-api"
  description = "Order API - An API for demonstrating CORS-enabled methods."
}

# 서버 측 오류에 CORS 헤더 추가 #
resource "aws_api_gateway_gateway_response" "response_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}

resource "aws_api_gateway_gateway_response" "response_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}

# CORS 를 위해서는 OPTIONS 이 필요하다.
resource "aws_api_gateway_method" "cors_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.order_api.id
  resource_id             = aws_api_gateway_resource.order_resource.id
  http_method             = aws_api_gateway_method.cors_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors_options_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = aws_api_gateway_method_response.cors_options_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    # "method.response.header.Access-Control-Allow-Headers" = "'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_lambda_function.order,
    aws_api_gateway_integration.cors_options_integration,
    aws_api_gateway_method_response.cors_options_response_200
  ]
}

# Lambda 프록시 통합에 대한 설정은 이곳에서 처리합니다.
# aws_api_gateway_integration 리소스를 사용하여 Lambda 함수와 연결하고, 응답 헤더를 구성합니다.




resource "aws_api_gateway_resource" "order_resource" {
  # 연결된 REST API의 ID
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  # 상위 API 리소스의 ID
  parent_id   = aws_api_gateway_rest_api.order_api.root_resource_id
  # 이 API 리소스의 마지막 경로 세그먼트
  path_part   = "order"
}

resource "aws_api_gateway_method" "order_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  # http_method   = "ANY"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "order_integration" {
    rest_api_id   = aws_api_gateway_rest_api.order_api.id
    resource_id   = aws_api_gateway_resource.order_resource.id
    http_method   = aws_api_gateway_method.order_method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.order.invoke_arn
}

# API Gateway 에 Lambda 함수 실행 권한 부여
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowOrderAPIInvoke"
  action        = "lambda:InvokeFunction"
  # function_name = aws_lambda_function.order.function_name
  function_name = aws_lambda_function.order.arn
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/*"
}

# deployment 는 REST API 구성의 스냅샷
resource "aws_api_gateway_deployment" "order_deployment" {
  # depends_on = [aws_api_gateway_integration.order_proxy_integration,]
  depends_on = [ aws_api_gateway_integration.order_integration ]

  rest_api_id = aws_api_gateway_rest_api.order_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.order_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "order_stage" {
  deployment_id = aws_api_gateway_deployment.order_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  stage_name  = "beta"

  lifecycle {
    create_before_destroy = true
  }
}