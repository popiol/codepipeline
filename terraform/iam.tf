resource "aws_iam_role" "ec2_role" {
	name = "${var.app_id}_ec2_role"
	path = "/${var.app}/${var.app_ver}/"

	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF

	tags = var.tags
}

resource "aws_iam_role_policy" "ec2_policy" {
	name = "${var.app_id}_kube_policy"
	role = aws_iam_role.ec2_role.name
	policy = data.aws_iam_policy_document.ec2_policy_doc.json
}

data "aws_iam_policy_document" "ec2_policy_doc" {
	statement {
		actions = [
			"ec2:*",
			"elasticloadbalancing:*",
			"ecr:GetAuthorizationToken",
			"ecr:BatchCheckLayerAvailability",
			"ecr:GetDownloadUrlForLayer",
			"ecr:GetRepositoryPolicy",
			"ecr:DescribeRepositories",
			"ecr:ListImages",
			"ecr:BatchGetImage",
			"route53:GetHostedZone",
			"route53:ListHostedZones",
			"route53:ListHostedZonesByName",
			"route53:ChangeResourceRecordSets",
			"route53:ListResourceRecordSets",
			"route53:GetChange"	
		]
		resources = [
			"*"
		]
	}
}

resource "aws_iam_instance_profile" "ec2_profile" {
	name = "${var.app_id}_ec2_role"
	role = aws_iam_role.ec2_role.name
}

