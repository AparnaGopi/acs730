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

# Lab 6 - Golden AMI vs Converge-on-Boot

## Runner-to-Instance Access

This lab uses AWS Systems Manager Session Manager (SSM) as the runner-to-instance access mechanism because it does not require inbound SSH access, an open port 22, or a long-lived private key stored in repository secrets.

## Idempotency

A second Ansible run reporting `changed=0` proves that the role checked the actual state of the host and found it already matched the desired configuration. This makes the playbook safe to run repeatedly on both new and already-configured instances.

## Why Deregistering an AMI Is Not Enough

Deregistering an AMI only removes the AMI record. The EBS snapshot that contains the image data remains and continues to consume storage until it is deleted separately.

## SSM Bucket and Region Requirement

The `amazon.aws.aws_ssm` connection plugin requires an S3 bucket in the same AWS region as the managed instances. In this lab the bucket was used by the plugin to transfer files during Ansible execution.

## Experiments

### Experiment 1: Converge on Boot

The instance launched from a base Amazon Linux image and was configured by Ansible after startup.

Time to ready: **XX seconds**

Included:
- EC2 launch time
- SSM agent registration
- Package installation through dnf
- Application deployment
- Service startup

### Experiment 2: Golden AMI

The instance launched from a pre-baked AMI containing the application and dependencies.

Time to ready: **XX seconds**

Included:
- EC2 launch time
- SSM agent registration (if measured)
- Application startup

Excluded:
- Packer build time (performed earlier during image creation)

## Comparison

| Method | Time (seconds) | Includes |
|----------|----------:|----------|
| Converge on Boot | XX | Launch, SSM registration, dnf downloads, configuration, service start |
| Golden AMI | XX | Launch and application startup from prebuilt image |

## Where the Time Went

The majority of the time in the converge-on-boot approach was spent waiting for the SSM agent to register and downloading packages through dnf. The actual Ansible configuration logic completed much faster than the dependency installation phase.

## Cost Shift of a Golden AMI

A golden AMI moves configuration work from launch time to image-build time. The cost is paid once during the Packer build rather than during every instance launch.

## What Breaks with Golden AMIs

Golden AMIs are a snapshot in time. Software updates released after the image is built are not included until a new image is created. Troubleshooting can also be more difficult because configuration details are embedded in the image rather than expressed directly in a playbook.

## What Breaks with Converge-on-Boot

Every instance launch depends on package repositories and network connectivity being available during provisioning. A repository outage or network issue can prevent new instances from becoming ready.

## Recommendation

I recommend the Golden AMI approach because it reduces launch time and produces consistent deployments when multiple instances are launched. I would prefer converge-on-boot only when the configuration changes frequently and rebuilding images would occur more often than launching instances.
