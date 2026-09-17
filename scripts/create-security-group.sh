#!/bin/bash
set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 <security-group-name> <vpc-id> <your-public-ip>"
    echo "Example: $0 lab1-sg vpc-12345678 203.0.113.10"
    exit 1
fi

SG_NAME=$1
VPC_ID=$2
MY_IP=$3

SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Lab1 SSH access" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr "${MY_IP}/32"

echo "$SG_ID"
