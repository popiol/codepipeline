resource "aws_codepipeline" "main" {
	name = var.app_id
	role_arn = aws_iam_role.codepipeline.arn
	tags = var.tags

	artifact_store {
		location = "codepipeline-${var.aws_region}-83040681529900"
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
