resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.order_api.id
  stage_name  = aws_api_gateway_stage.order_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

output "custom_domain_api" {
  value = "https://${aws_api_gateway_base_path_mapping.api.domain_name}"
}

resource "aws_api_gateway_base_path_mapping" "api_v1" {
  api_id      = aws_api_gateway_rest_api.order_api.id
  stage_name  = aws_api_gateway_stage.order_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
  base_path = "v1"
}

output "custom_domain_api_v1" {
  value = "https://${aws_api_gateway_base_path_mapping.api.domain_name}/${aws_api_gateway_base_path_mapping.api_v1.base_path}"
}
