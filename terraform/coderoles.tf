resource "aws_iam_role" "codebuild" {
	name = "${var.app_id}_codebuild"
	assume_role_policy = data.aws_iam_policy_document.coderole_assume.json
	tags = var.tags
}

data "aws_iam_policy_document" "coderole_assume" {
	statement {
		actions = [
			"sts:AssumeRole"
		]
		principals {
			type = "Service"
			identifiers = [
				"codebuild.amazonaws.com"
			]
		}
	}
}

resource "aws_iam_role_policy" "codebuild_policy" {
	name = "${var.app_id}_codebuild"
	role = aws_iam_role.codebuild.name
	policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
	statement {
		actions = [
			"ec2:CreateNetworkInterface",
			"ec2:DescribeDhcpOptions",
			"ec2:DescribeNetworkInterfaces",
			"ec2:DeleteNetworkInterface",
			"ec2:DescribeSubnets",
			"ec2:DescribeSecurityGroups",
			"ec2:DescribeVpcs"
		]
		resources = [
			"*"
		]
	}

	statement {
		actions = [
			"ec2:CreateNetworkInterfacePermission"
		]
		resources = [
			"arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
		]
		condition {
			test = "StringEquals"
			variable = "ec2:Subnet"
			values = [
				aws_subnet.subnet2.arn
			]
		}
		condition {
			test = "StringEquals"
			variable = "ec2:AuthorizedService"
			values = [
				"codebuild.amazonaws.com"
			]
		}
	}

	statement {
		actions = [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents"
		]
		resources = [
			"*"
		]
	}

	statement {
		actions = [
			"s3:PutObject",
			"s3:GetObject",
			"s3:GetObjectVersion",
			"s3:GetBucketAcl",
			"s3:GetBucketLocation"
		]
		resources = [
			"arn:aws:s3:::${replace(var.app_id,"_","-")}-codepipeline-${data.aws_caller_identity.current.account_id}"
		]
	}

	statement {
		actions = [
			"codebuild:CreateReportGroup",
			"codebuild:CreateReport",
			"codebuild:UpdateReport",
			"codebuild:BatchPutTestCases"
		]
		resources = [
			"arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:report-group/${var.app}-*"
		]
	}

	statement {
		actions = [
			"ecr:*"
		]
		resources = [
			"*"
		]
	}
}

resource "aws_iam_role" "codepipeline" {
	name = "${var.app_id}_codepipeline"
	assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
	tags = var.tags
}

data "aws_iam_policy_document" "codepipeline_assume" {
	statement {
		actions = [
			"sts:AssumeRole"
		]
		principals {
			type = "Service"
			identifiers = [
				"codepipeline.amazonaws.com"
			]
		}
	}
}

resource "aws_iam_role_policy" "codepipeline_policy" {
	name = "${var.app_id}_codepipeline"
	role = aws_iam_role.codepipeline.name
	policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
	statement {
		actions = [
			"ima:PassRole",
			"codecommit:CancelUploadArchive",
			"codecommit:GetBranch",
			"codecommit:GetCommit",
			"codecommit:GetUploadArchiveStatus",
			"codecommit:UploadArchive",
			"codedeploy:CreateDeployment",
			"codedeploy:GetApplication",
			"codedeploy:GetApplicationRevision",
			"codedeploy:GetDeployment",
			"codedeploy:GetDeploymentConfig",
			"codedeploy:RegisterApplicationRevision",
			"ec2:*",
			"ecr:*",
			"elasticloadbalancing:*",
			"autoscaling:*",
			"cloudwatch:*",
			"s3:*",
			"sns:*",
			"cloudformation:*",
			"rds:*",
			"sqs:*",
			"ecs:*",
			"lambda:InvokeFunction",
			"lambda:ListFunctions",
			"codebuild:BatchGetBuilds",
			"codebuild:StartBuild"
		]
		resources = [
			"*"
		]
	}
}

