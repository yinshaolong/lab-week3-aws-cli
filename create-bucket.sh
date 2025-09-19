#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

bucket_name=$1
region="us-west-2"

echo "Checking if bucket '$bucket_name' exists in $region..."

if aws s3api head-bucket --bucket "$bucket_name" --region "$region" 2>/dev/null; then
    echo "Bucket '$bucket_name' already exists."
else
    echo "Creating bucket '$bucket_name' in $region..."
    aws s3api create-bucket \
      --bucket "$bucket_name" \
      --region "$region" \
      --create-bucket-configuration LocationConstraint="$region"
    echo "Bucket '$bucket_name' created in $region."
fi
