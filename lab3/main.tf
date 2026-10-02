terraform {
  required_version = "~> 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "acs730-tfstate-532264255350"
    key          = "lab3/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

