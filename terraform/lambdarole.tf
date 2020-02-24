resource "aws_iam_role" "lambdarole" {
	name = "${var.app_id}_role"
	assume_role_policy = data.aws_iam_policy_document.lambdarole_doc.json
}

data "aws_iam_policy_document" "lambdarole_doc" {
	statement {
		actions = [
			"sts:AssumeRole"
		]
		principals {
			type = "Service"
			identifiers = [
				"lambda.amazonaws.com",
			]
		}
	}
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
	role = aws_iam_role.lambdarole.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_policies" {
	name = "${var.app_id}_lambda_policies"
	role = aws_iam_role.lambdarole.id
	policy = data.aws_iam_policy_document.lambda_policies_doc.json
}

data "aws_iam_policy_document" "lambda_policies_doc" {
	statement {
		actions = [
			"s3:GetObject",
			"s3:PutObject",
			"s3:DeleteObject"
		]
		resources = [
			"arn:aws:s3:::${var.keys_bucket}/*"
		]
	}

	statement {
		actions = [
			"lambda:*"
		]
		resources = [
			"*"
		]
	}

	statement {
		actions = [
			"ec2:*"
		]
		resources = [
			"*"
		]
	}

	statement {
		actions = [
			"codepipeline:PutJobSuccessResult",
			"codepipeline:PutJobFailureResult"
		]
		resources = [
			"*"
		]
	}
}

