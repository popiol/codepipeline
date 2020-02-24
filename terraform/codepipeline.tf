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
				Owner = "popiol"
				Branch = var.app_ver
				Repo = "semantive"
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
