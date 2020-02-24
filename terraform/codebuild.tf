resource "aws_codebuild_project" "main" {
	name = var.app_id
	build_timeout = "5"
	service_role = aws_iam_role.codebuild.arn
	tags = var.tags

	artifacts {
		type = "NO_ARTIFACTS"
	}

	environment {
		compute_type = "BUILD_GENERAL1_SMALL"
		image = "aws/codebuild/standard:1.0"
		type = "LINUX_CONTAINER"
		privileged_mode = "true"

		environment_variable {
			name = "AWS_DEFAULT_REGION"
			value = var.aws_region
		}

		environment_variable {
			name = "AWS_ACCOUNT_ID"
			value = data.aws_caller_identity.current.account_id 
		}

		environment_variable {
			name = "IMAGE_TAG"
			value = "latest"
		}

		environment_variable {
			name = "IMAGE_REPO_NAME"
			value = aws_ecr_repository.main.name
		}
	}

	source {
		type = "GITHUB"
		location = "https://github.com/${var.github_user}/${var.github_repo}"
		git_clone_depth = 1
	}

	source_version = var.app_ver

	vpc_config {
		vpc_id = aws_vpc.vpc1.id
		subnets = [
			aws_subnet.subnet2.id
		]
		security_group_ids = [
			aws_security_group.sec_gr1.id
		]
	}
}

