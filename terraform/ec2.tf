data "template_cloudinit_config" "init" {
	gzip = true
	base64_encode = true

	part {
		filename = "ec2_init.sh"
		content_type = "text/x-shellscript"
		content = templatefile("${path.module}/../config/ec2_init.sh", {
			vimrc: file("${path.module}/../config/vimrc.local"),
			timezone: var.timezone,
			docker_compose: file("${path.module}/../docker-compose.yml"),
			aws_region: var.aws_region,
			aws_account_id: data.aws_caller_identity.current.account_id,
			image_tag: "latest", 
			app_id: var.app_id,
			crud_rest_key: var.crud_rest_key
		})
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
	instance_type = "t3a.medium"
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

