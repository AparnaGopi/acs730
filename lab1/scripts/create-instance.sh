#!/bin/bash
set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 <ami-id> <instance-type> <security-group-id>"
    exit 1
fi

AMI_ID=$1
INSTANCE_TYPE=$2
SG_ID=$3

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --security-group-ids "$SG_ID" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "$INSTANCE_ID"
