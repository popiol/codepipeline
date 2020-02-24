variable "aws_region" {
	type = string
}

variable "tags" {
	type = map(string)
}

variable "app_id" {
	type = string
}

variable "app" {
	type = string
}

variable "app_ver" {
	type = string
}

variable "ssh_pub_key" {
	type = string
}

variable "ssh_priv_key" {
	type = string
}

variable "statefile_bucket" {
	type = string
}

variable "timezone" {
	type = string
}

variable "keys_bucket" {
	type = string
}

variable "github_token" {
	type = string
}

variable "github_user" {
	type = string
}

variable "github_repo" {
	type = string
}

