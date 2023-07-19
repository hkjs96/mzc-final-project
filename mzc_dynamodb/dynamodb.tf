resource "aws_dynamodb_table" "order-history-dynamodb-table" {
  name           = "OrderHistory"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "orderNo"    # 기본 키  
  range_key      = "customerName"  # 기본 키와 같이 쓰여 정렬에 이용

  # attribute 에 들어가는 것들은 키 또는 인덱스에 사용될 녀석들만 선언

  attribute {
    name = "orderNo"
    type = "S"
  }

  attribute {
    name = "customerName"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "order-history-dynamodb-table"
    Environment = "production"
  }
}