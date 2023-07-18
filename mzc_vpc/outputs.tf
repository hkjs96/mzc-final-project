output "aws_vpc_name" {
  value       = aws_vpc.ap-northeast-2_vpc.tags.Name
  description = "The name of the VPC"
}

output "public_subnet_ids" {
  value = aws_subnet.ap-northeast-2-pub_2[*].id
  description = "The id of the public subent"
}

output "public_subnet_names" {
  value = aws_subnet.ap-northeast-2-pub_2[*].tags.Name
  description = "The name of the public subnet"
}

output "private_subnet_ids" {
  value = aws_subnet.ap-northeast-2-pvt_2[*].id
  description = "The id of the public subent"
}

output "private_subnet_names" {
  value = aws_subnet.ap-northeast-2-pvt_2[*].tags.Name
  description = "The name of the public subnet"
}

output "nat" {
  value = aws_nat_gateway.ap-northeast-2-ngw[*].tags.Name
}

output "igw" {
  value = aws_internet_gateway.ap-northeast-2-igw
}

output "pub_route_table_route" {
  value = aws_route_table_association.ap-northeast-2-pub_2_association[*]
}

output "pvt_route_table_route_a" {
  value = aws_route_table_association.ap-northeast-2-pvt_2a_association
}
output "pvt_route_table_route_b" {
  value = aws_route_table_association.ap-northeast-2-pvt_2b_association
}
output "pvt_route_table_route_c" {
  value = aws_route_table_association.ap-northeast-2-pvt_2c_association
}
output "pvt_route_table_route_d" {
  value = aws_route_table_association.ap-northeast-2-pvt_2d_association
}