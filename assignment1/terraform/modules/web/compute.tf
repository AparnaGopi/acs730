# AMI ids are regional and change whenever Amazon publishes a build, so
# look up the latest one instead of hardcoding it.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

locals {
  ami_id = data.aws_ami.al2023.id

  # keys() on a map returns sorted order, so this is stable across runs.
  first_subnet_key = keys(local.public_subnets)[0]
}

resource "aws_instance" "web" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[local.first_subnet_key].id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf -y install nginx
    echo "<h1>ACS730 Assignment 1 - ${local.name}</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT

  # The route table association is not implied by any reference, and
  # user_data needs a route to the internet before it can install nginx.
  depends_on = [aws_route_table_association.public]

  tags = merge(local.common_tags, { Name = "${local.name}-web" })
}
