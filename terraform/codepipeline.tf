resource "aws_codepipeline" "main" {
	name = var.app_id
	role_arn = aws_iam_role.codepipeline.arn
	tags = var.tags

	artifact_store {
		location = aws_s3_bucket.codepipeline.bucket
		type = "S3"
	}

	stage {
		name = "Source"

		action {
			name = "Source"
			category = "Source"
			owner = "ThirdParty"
			provider = "GitHub"
			version = "1"
			output_artifacts = ["source_output"]

			configuration = {
				Owner = var.github_user
				Branch = var.app_ver
				Repo = var.github_repo
				PollForSourceChanges = "false"
				OAuthToken = var.github_token
			}
		}
	}

	stage {
		name = "Build"

		action {
			name = "Build"
			category = "Build"
			owner = "AWS"
			provider = "CodeBuild"
			input_artifacts = ["source_output"]
			output_artifacts = ["build_output"]
			version = "1"

			configuration = {
				ProjectName = var.app_id
			}
		}
	}

	stage {
		name = "Deploy"

		action {
			name = "Deploy"
			category = "Invoke"
			owner = "AWS"
			provider = "Lambda"
			input_artifacts = ["build_output"]
			version = "1"

			configuration = {
				FunctionName = "${var.app_id}_deploy"
			}
		}
	}
}

resource "aws_codepipeline_webhook" "main" {
	name = var.app_id
	authentication = "GITHUB_HMAC"
	target_action = "Source"
	target_pipeline = aws_codepipeline.main.name

	authentication_configuration {
		secret_token = var.github_token
	}

	filter {
		json_path = "$.ref"
		match_equals = "refs/heads/{Branch}"
	}
}

provider "github" {
	token = var.github_token
	organization = "popiol"
}


#resource "github_repository" "main" {
#	name = var.app_id
#	private = true
#}

resource "github_repository_webhook" "main" {
	#repository = github_repository.main.name
	repository = var.github_repo

	configuration {
		url = aws_codepipeline_webhook.main.url
		content_type = "json"
		insecure_ssl = true
		secret = var.github_token
	}

	events = ["push"]
}

resource "aws_s3_bucket_object" "priv_key" {
	bucket = var.keys_bucket
	key = "${var.app}/${var.app_ver}/semantive.pem"
	source = var.ssh_priv_key 
	etag = filemd5(var.ssh_priv_key)
}

