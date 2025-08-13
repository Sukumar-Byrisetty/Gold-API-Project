#!/bin/bash
set -euo pipefail

SOURCE_DIR="$1"
BUCKET_NAME="$2"

if [ -z "$SOURCE_DIR" ] || [ -z "$BUCKET_NAME" ]; then
  echo "Usage: $0 <source_dir> <bucket_name>"
  exit 1
fi

echo "Removing existing files from S3: $BUCKET_NAME"
aws s3 rm "s3://$BUCKET_NAME" --recursive

echo "Uploading from $SOURCE_DIR to S3 bucket: $BUCKET_NAME"
aws s3 sync "$SOURCE_DIR" "s3://$BUCKET_NAME"
