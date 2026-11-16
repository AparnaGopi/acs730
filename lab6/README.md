# Lab 6

Instructions for this section will be provided in class and on Blackboard when we reach it.

Put your work for Lab 6 in this folder.
# Lab 6 README

## Design Decisions

### 1. No runner IP address is required

This solution uses AWS Systems Manager (SSM) rather than SSH. The GitHub Actions runner never connects directly to the EC2 instances, so no runner IP lookup, SSH CIDR updates, or temporary security group rules are required. The connection is initiated through SSM from the instance, reducing network exposure and simplifying automation.

### 2. Tool installation occurs before provisioning

All required tools are installed before Terraform apply and Ansible provisioning steps are executed. This minimizes the time between infrastructure creation and configuration, ensuring the environment is ready immediately after resources become available.

### 3. Session Manager Plugin is installed explicitly

The Session Manager Plugin is installed in the workflow even if it is already available on a developer workstation. CI runners are provisioned from clean environments and do not contain this dependency by default. Installing it explicitly prevents failures such as "SessionManagerPlugin is not found" during Ansible execution.

### 4. Retry loop before Ansible execution

Terraform reports success when an EC2 instance reaches the running state, but the SSM agent may require additional time to register with AWS Systems Manager. A retry loop is used before running the Ansible playbook to ensure the instance is available through SSM. This prevents intermittent pipeline failures that occur immediately after infrastructure deployment.
