# Read at plan time. The value is never written in code or output.
data "aws_ssm_parameter" "db_password" {
  name = var.db_password_parameter_name
}
