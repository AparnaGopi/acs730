# Lab 3

Instructions for this section will be provided in class and on Blackboard when we reach it.

Put your work for Lab 3 in this folder.
## Tools Used

Terraform was used to provision the AWS infrastructure for this lab.

### Version Verification

terraform version v1.10.3

Authentication Notes
A real AWS account would use OIDC because GitHub Actions can exchange a short-lived identity token for temporary AWS credentials, eliminating the need to store long-term access keys in repository secrets.

This course uses session-scoped AWS credentials because AWS Academy does not allow the IAM configuration required for OIDC. If these credentials leak, the impact is limited because they are temporary and automatically expire when the lab session ends.
