#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <security-group-id>"
    exit 1
fi

SG_ID=$1

aws ec2 delete-security-group \
    --group-id "$SG_ID"

echo "Deleted security group: $SG_ID"
