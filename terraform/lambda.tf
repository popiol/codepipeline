resource "aws_lambda_function" "deploy" {
	filename = "lambda/deploy.zip"
	function_name = "${var.app_id}_deploy"
	role = aws_iam_role.lambdarole.arn
	handler = "main.lambda_handler"
	source_code_hash = filebase64sha256("lambda/deploy.zip")
	runtime = "python3.7"
	timeout = 300
	tags = var.tags

	vpc_config {
		subnet_ids = [
			aws_subnet.subnet2.id
		]
		security_group_ids = [aws_security_group.sec_gr1.id]
	}

	environment {
		variables = {
			keys_bucket = var.keys_bucket
			key_name = "${var.app}/${var.app_ver}/semantive.pem"
			app_ver = var.app_ver
		}
	}
}

