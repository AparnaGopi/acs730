#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <instance-id>"
    exit 1
fi

INSTANCE_ID=$1

aws ec2 terminate-instances \
    --instance-ids "$INSTANCE_ID" \
    >/dev/null

echo "Deleted instance: $INSTANCE_ID"
