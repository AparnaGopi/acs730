provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Course = "ACS730"
      Owner  = "aparna"
    }
  }
}

module "web" {
  source = "../modules/web"

  environment   = "staging"
  owner         = "aparna"
  instance_type = "t3.micro"
  vpc_cidr      = "10.20.0.0/16"

  public_subnets = {
    a = { cidr_block = "10.20.1.0/24", az_index = 0 }
    b = { cidr_block = "10.20.2.0/24", az_index = 1 }
  }
}

output "instance_id" {
  value = module.web.instance_id
}

output "web_url" {
  value = module.web.web_url
}
