# Save the file terraform.tfstate in S3.

terraform {
  backend "s3" {
    bucket = "shlomo-project-ci-cd"
    key    = "project-devops/terraform.tfstate"
    region = "us-east-1"
  }
}


