resource "aws_s3_bucket" "codepipeline" {
	bucket = "popiol.${replace(var.app_id,"_","-")}-codepipeline"
	acl    = "private"
	tags = var.tags
}

