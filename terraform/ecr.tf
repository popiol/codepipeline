resource "aws_ecr_repository" "main" {
	name = var.app_id
	tags = var.tags
}

