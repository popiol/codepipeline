resource "aws_vpc" "vpc1" {
	cidr_block = "172.16.0.0/16"
	tags = var.tags
}

resource "aws_subnet" "subnet1" {
	vpc_id = aws_vpc.vpc1.id
	cidr_block = "172.16.10.0/24"
	availability_zone = "${data.aws_region.current.name}a"
	tags = var.tags
}

resource "aws_subnet" "subnet2" {
	vpc_id = aws_vpc.vpc1.id
	cidr_block = "172.16.20.0/24"
	availability_zone = "${data.aws_region.current.name}b"
	tags = var.tags
}

resource "aws_security_group" "sec_gr1" {
	name = "${var.app_id}_sec_gr1"
	vpc_id = aws_vpc.vpc1.id

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 9000
		to_port = 9000
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = var.tags
}

resource "aws_internet_gateway" "gateway1" {
	vpc_id = aws_vpc.vpc1.id
	tags = var.tags
}

resource "aws_nat_gateway" "nat1" {
	allocation_id = aws_eip.eip2.id
	subnet_id = aws_subnet.subnet1.id
	tags = var.tags
}

resource "aws_route_table" "route1" {
	vpc_id = aws_vpc.vpc1.id
	tags = var.tags

    route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gateway1.id
	}
}

resource "aws_route_table" "route2" {
	vpc_id = aws_vpc.vpc1.id
	tags = var.tags

    route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_nat_gateway.nat1.id
	}
}

resource "aws_route_table_association" "route1_subnet1" {
	subnet_id = aws_subnet.subnet1.id
	route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "route2_subnet2" {
	subnet_id = aws_subnet.subnet2.id
	route_table_id = aws_route_table.route2.id
}

resource "aws_eip" "eip2" {
	vpc = true
}

