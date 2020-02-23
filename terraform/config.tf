terraform {
	backend "s3" {
		bucket = "popiol.state-files"
		key    = "semantive/prod/tfstate"
		region = "us-east-2"
	}
}

