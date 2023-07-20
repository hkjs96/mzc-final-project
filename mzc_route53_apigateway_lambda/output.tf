output "order-lambda-api-invoke_url" {
  # value = aws_apigatewayv2_stage.example_stage.invoke_url
  value = aws_api_gateway_stage.order_stage.invoke_url
}

output "aws_acm_certificate-status" {
  value = aws_acm_certificate.api.status
}