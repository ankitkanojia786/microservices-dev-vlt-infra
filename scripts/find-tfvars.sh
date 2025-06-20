#!/bin/bash
TFVARS_FILE=$(find .. -name "usdev-usw2.tfvars" -type f 2>/dev/null | head -1)
if [ -z "$TFVARS_FILE" ]; then
    TFVARS_FILE=$(find .. -name "*.tfvars" -type f 2>/dev/null | head -1)
fi
echo "$TFVARS_FILE"