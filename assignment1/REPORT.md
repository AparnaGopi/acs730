# Assignment 1: Multi-Environment Deploy
# 1. Introduction
<!-- What did you build? How does a change get from a PR to prod? -->

I built a Terraform-based CI/CD pipeline using GitHub Actions, AWS OIDC, GitHub Environments, Secrets Manager, and CloudWatch.

A change starts with a Pull Request (PR). GitHub Actions runs validation checks. After approval and merge, the deployment is promoted through staging and production using environment-specific approvals and IAM roles.

---

# 2. Reusable Module
<!-- What did you start from? List the inputs and outputs. Why those? -->

I created a reusable Terraform module to avoid duplicating infrastructure code.

### Inputs
- `environment`
- `instance_type`
- `instance_count`
- `secret_name`

### Outputs
- `instance_ids`
- `public_ips`
- `secret_arn`

Using inputs and outputs makes the module flexible and reusable across environments.

---

# 3. Environment Directories
<!-- What differs between dev, staging and prod? How are state keys separated? -->

### Differences

**Dev**
- Testing environment
- Smallest deployment
- No approval required

**Staging**
- Production-like environment
- Requires approval

**Prod**
- Live environment
- Strict approval rules

### State Separation

```hcl
dev/terraform.tfstate
staging/terraform.tfstate
prod/terraform.tfstate
```

Separate state keys prevent environments from affecting each other.

---

# 4. GitHub Environments
<!-- Approval and branch rules. Why was dev only validated in CI? -->

Three GitHub Environments were used:

- Dev
- Staging
- Prod

### Rules

- Dev: CI validation only
- Staging: Manual approval required
- Prod: Manual approval and branch restrictions

Dev was only validated in CI to allow faster testing without approval delays.

---

# 5. Scoped Credentials and OIDC Trust Policy
<!-- What moved where? Add your JSON, then explain what each condition prevents. -->

AWS access keys were removed from GitHub and replaced with OIDC-based authentication.

### Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:environment:prod"
        }
      }
    }
  ]
}
```

### Conditions

- `aud` ensures the token is intended for AWS STS.
- `sub` restricts access to a specific repository and environment.

---

# 6. Real Deployment
<!-- Describe both promotions and link the evidence. -->

### Dev → Staging

1. PR merged
2. GitHub Actions ran
3. Approval granted
4. Terraform deployed to staging

**Evidence:** Add workflow screenshot here.

### Staging → Prod

1. Staging validated successfully
2. Production approval granted
3. Terraform deployed to production

**Evidence:** Add workflow screenshot here.

---

# 7. Secrets Management
<!-- How is the value created and read? Where is it still exposed? -->

The secret was stored in AWS Secrets Manager.

### Create

```bash
aws secretsmanager create-secret
```

### Read

```bash
aws secretsmanager get-secret-value
```

The secret can still be exposed through logs, application memory, or overly permissive IAM permissions.

---

# 8. CloudWatch Alarm
<!-- Metric, threshold, period, and what you would do if it fired. Any limits? -->

### Configuration

- Metric: CPUUtilization
- Threshold: 80%
- Period: 5 minutes
- Evaluation Periods: 2

### Response

If the alarm fires, I would review CloudWatch metrics, check logs, and determine whether scaling or troubleshooting is required.

### Limits

CPU usage alone may not detect all application issues.

---

# 9. Recommendation
<!-- One page. GitHub Actions or AWS-native? At least three concrete factors. -->

I recommend **GitHub Actions**.

### Reasons

1. Integrated directly with GitHub repositories.
2. Supports secure OIDC authentication.
3. Easy to manage CI/CD workflows.

AWS-native tools provide deeper AWS integration, but GitHub Actions offers better simplicity and developer experience for small teams.

---

# 10. Conclusion
<!-- What worked, what broke, what you would change. Confirm cleanup. -->

The CI/CD pipeline successfully deployed infrastructure across multiple environments using Terraform and GitHub Actions.

### What Worked

- Reusable Terraform modules
- OIDC authentication
- Environment approvals

### What Broke

- IAM trust policy configuration
- Terraform state management

### Future Improvements

- Add more monitoring
- Implement automated rollback
- Add security scanning

### Cleanup

All test resources were reviewed and cleaned up to avoid unnecessary AWS charges.
