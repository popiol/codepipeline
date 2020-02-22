terraform {
	backend "s3" {
		bucket = var.statefile-bucket
		key    = "${var.app}/${var.app_ver}/tfstate"
		region = var.aws_region
	}
}

