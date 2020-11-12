resource "aws_vpc" "kakeibo_vpc" {
  cidr_block           = var.vpc_cider_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.default_tags, map("Name", "kakeibo-vpc"))
}

resource "aws_subnet" "kakeibo_public_subnets" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.kakeibo_vpc.id
  availability_zone       = each.value.zone
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.launch
  tags                    = merge(local.default_tags, local.eks_tag, local.elb_tag, each.value.name)
}

resource "aws_subnet" "kakeibo_private_subnets" {
  for_each                = local.private_subnets
  vpc_id                  = aws_vpc.kakeibo_vpc.id
  availability_zone       = each.value.zone
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.launch
  tags                    = merge(local.default_tags, local.eks_tag, local.internal_elb_tag, each.value.name)
}

resource "aws_internet_gateway" "kakeibo_internet_gateway" {
  vpc_id = aws_vpc.kakeibo_vpc.id
  tags   = merge(local.default_tags, map("Name", "kakeibo-internet-gateway"))
}

resource "aws_route_table" "kakeibo_public_route_table" {
  vpc_id = aws_vpc.kakeibo_vpc.id
  tags   = merge(local.default_tags, map("Name", "kakeibo-public-route-table"))

  route {
    gateway_id = aws_internet_gateway.kakeibo_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "kakeibo_sb_rtb_public" {
  count          = length(local.public_subnet_ids)
  subnet_id      = element(local.public_subnet_ids, count.index)
  route_table_id = aws_route_table.kakeibo_public_route_table.id
}

resource "aws_eip" "nat_gateway_eip" {
  count      = length(var.availability_zones)
  vpc        = true
  depends_on = [aws_internet_gateway.kakeibo_internet_gateway]
  tags       = merge(local.default_tags, map("Name", format("kakeibo-nat-gateway-eip-%s", element(var.availability_zones, count.index))))
}

resource "aws_nat_gateway" "kakeibo_nat_gateway" {
  count         = length(var.availability_zones)
  allocation_id = element(aws_eip.nat_gateway_eip.*.id, count.index)
  subnet_id     = element(local.public_subnet_ids, count.index)
  depends_on    = [aws_internet_gateway.kakeibo_internet_gateway]
  tags          = merge(local.default_tags, map("Name", format("kakeibo-nat-gateway-%s", element(var.availability_zones, count.index))))
}

resource "aws_route_table" "kakeibo_private_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.kakeibo_vpc.id
  tags   = merge(local.default_tags, map("Name", format("kakeibo-private-route-table-%s", element(var.availability_zones, count.index))))

  route {
    nat_gateway_id = element(aws_nat_gateway.kakeibo_nat_gateway.*.id, count.index)
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "kakeibo_sb_rtb_private" {
  count          = length(local.private_subnet_ids)
  subnet_id      = element(local.private_subnet_ids, count.index)
  route_table_id = element(aws_route_table.kakeibo_private_route_table.*.id, count.index)
}
