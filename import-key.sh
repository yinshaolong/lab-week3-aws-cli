#!/bin/bash
# Script to import a public key into AWS as 'bcitkey'
# AWS CLI Reference: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/import-key-pair.html

# Path to your public key file (update if needed)
PUB_KEY_FILE="bcitkey.pub"

if [ ! -f "$PUB_KEY_FILE" ]; then
  echo "Public key file '$PUB_KEY_FILE' not found!"
  exit 1
fi

aws ec2 import-key-pair \
  --key-name "bcitkey" \
  --public-key-material "$(cat $PUB_KEY_FILE | base64)"

echo "Key 'bcitkey' imported to AWS."
