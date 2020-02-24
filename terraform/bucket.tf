resource "aws_s3_bucket" "codepipeline" {
	bucket = "${replace(var.app_id,"_","-")}-codepipeline-${data.aws_caller_identity.current.account_id}"
	acl    = "private"
	tags = var.tags
}

