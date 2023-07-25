### vpc ###

resource "aws_vpc" "ap-northeast-2_vpc" {
  cidr_block  = "172.100.0.0/16"
  enable_dns_hostnames = true 
  enable_dns_support = true 
  instance_tenancy = "default"

  tags = {
    Name = "ap-northeast-2-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "ap-northeast-2-pub_2" {
  count             = 4
  vpc_id            = aws_vpc.ap-northeast-2_vpc.id
  map_public_ip_on_launch = true
  cidr_block        = "172.100.${count.index * 16}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = element(sort([
      "ap-northeast-2-pub_2a",
      "ap-northeast-2-pub_2b", 
      "ap-northeast-2-pub_2c", 
      "ap-northeast-2-pub_2d"
    ]), count.index)    

    # AWS Load Balancer Controller 이용시 사용
    "kubernetes.io/role/elb"	            = 1  # 1 or ""
    "kubernetes.io/cluster/eks-cluster"   = "shared" # "shared" or "owned"
  }
}

resource "aws_subnet" "ap-northeast-2-pvt_2" {
  count             = 4
  vpc_id            = aws_vpc.ap-northeast-2_vpc.id
  map_public_ip_on_launch = false
  cidr_block        = "172.100.${(4 + count.index) * 16}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = element(sort([
      "ap-northeast-2-pvt_2a", 
      "ap-northeast-2-pvt_2b", 
      "ap-northeast-2-pvt_2c", 
      "ap-northeast-2-pvt_2d"
    ]), count.index)
    
    # AWS Load Balancer Controller 이용시 사용
    "kubernetes.io/role/elb"                   = 1  # 1 or ""
    "kubernetes.io/cluster/eks-cluster"   = "owned" # "shared" or "owned"
  }
}

# 퍼블릭 서브넷을 위한 IGW
resource "aws_internet_gateway" "ap-northeast-2-igw" {
  vpc_id = aws_vpc.ap-northeast-2_vpc.id
  tags = {
    Name = "ap-northeast-2-igw"
  }
}

# 프라이빗 서브넷의 EKS 클러스터를 위한 NAT GW
resource "aws_eip" "ngw" {
  count = 2
  tags = {
    Name = "nat-gateway-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "ap-northeast-2-ngw" {
  count         = 2

  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.ap-northeast-2-pub_2[count.index * 2].id # 반드시 퍼블릭 서브넷
	
  tags = {
    Name = "ap-northeast-2-ngw-${count.index}"
  }
}

resource "aws_route_table" "ap-northeast-2_pub_rtb" {
  vpc_id = aws_vpc.ap-northeast-2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ap-northeast-2-igw.id
  }
  tags = {
    Name = "ap-northeast-2-pub-rtb"
  }
}

resource "aws_route_table" "ap-northeast-2_pvt_rtb" {
  count  = 2
  vpc_id = aws_vpc.ap-northeast-2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ap-northeast-2-ngw[count.index].id
  }
  tags = {
    Name = "ap-northeast-2-pvt-rtb-${count.index}"
  }
}

resource "aws_route_table_association" "ap-northeast-2-pub_2_association" {
  count          = 4
  subnet_id      = aws_subnet.ap-northeast-2-pub_2[count.index].id
  route_table_id = aws_route_table.ap-northeast-2_pub_rtb.id
}

resource "aws_route_table_association" "ap-northeast-2-pvt_2a_association" {
  subnet_id      = aws_subnet.ap-northeast-2-pvt_2[0].id
  route_table_id = aws_route_table.ap-northeast-2_pvt_rtb[0].id
}
resource "aws_route_table_association" "ap-northeast-2-pvt_2b_association" {
  subnet_id      = aws_subnet.ap-northeast-2-pvt_2[1].id
  route_table_id = aws_route_table.ap-northeast-2_pvt_rtb[0].id
}
resource "aws_route_table_association" "ap-northeast-2-pvt_2d_association" {
  subnet_id      = aws_subnet.ap-northeast-2-pvt_2[3].id
  route_table_id = aws_route_table.ap-northeast-2_pvt_rtb[0].id
}
resource "aws_route_table_association" "ap-northeast-2-pvt_2c_association" {
  subnet_id      = aws_subnet.ap-northeast-2-pvt_2[2].id
  route_table_id = aws_route_table.ap-northeast-2_pvt_rtb[1].id
}

### SG - Security Group ###

resource "aws_security_group" "ap-northeast-2-vpc-sg" {
  name   = var.security_group_name
  vpc_id = aws_vpc.ap-northeast-2_vpc.id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}