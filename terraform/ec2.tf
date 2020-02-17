data "template_file" "init_sh" {
	template = file("../scripts/init.sh")
}

data "template_cloudinit_config" "init" {
	gzip = true
	base64_encode = true

	part {
		filename = "init.sh"
		content_type = "text/x-shellscript"
		content = data.template_file.init_sh.rendered
	}
}

resource "aws_key_pair" "keypair1" {
	key_name = var.app_id
	public_key = file(var.ssh_pub_key)
}

data "aws_ami" "ubuntu" {
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu*"]
	}

	owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2" {
	instance_type = "t2.micro"
	ami = data.aws_ami.ubuntu.id
	key_name = aws_key_pair.keypair1.key_name
	subnet_id = aws_subnet.subnet1.id
	associate_public_ip_address = false
	iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
	user_data_base64 = data.template_cloudinit_config.init.rendered

	vpc_security_group_ids = [
		aws_security_group.sec_gr1.id,
	]

	tags = var.tags
}

resource "aws_eip" "eip1" {
	instance = aws_instance.ec2.id
	vpc = true
}

