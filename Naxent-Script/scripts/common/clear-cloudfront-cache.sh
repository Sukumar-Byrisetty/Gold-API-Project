#!/bin/bash
set -euo pipefail

DISTRIBUTION_ID="$1"

if [ -z "$DISTRIBUTION_ID" ]; then
  echo "Usage: $0 <cloudfront_distribution_id>"
  exit 1
fi

echo "Creating CloudFront invalidation..."

INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*" \
  --query 'Invalidation.Id' --output text)

while true; do
  STATUS=$(aws cloudfront get-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --id "$INVALIDATION_ID" \
    --query 'Invalidation.Status' --output text)
  echo "Status: $STATUS"
  [ "$STATUS" = "Completed" ] && break
  sleep 5
done

echo "CloudFront invalidation completed."
