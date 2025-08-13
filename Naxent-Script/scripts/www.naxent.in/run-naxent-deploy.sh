#!/bin/bash
set -euo pipefail
trap 'echo "Deployment failed on line $LINENO"; exit 1' ERR

ENV="${1:-}"

if [[ ! "$ENV" =~ ^(test|development|production)$ ]]; then
  echo "Invalid or missing environment."
  echo "Usage: $0 [test|development|production]"
  exit 1
fi

ENV_PATH="/home/ec2-user/naxent-deploy/$ENV/environment.sh"

if [[ ! -f "$ENV_PATH" ]]; then
  echo "Environment file not found: $ENV_PATH"
  exit 1
fi

echo "Loading environment: $ENV"
source "$ENV_PATH"

# ========================
# Step 1: Pull Config and Source Repos
# ========================
echo "Pulling latest config repo..."
/home/ec2-user/naxent-deploy/scripts/www.naxent.in/get-latest-from-bitbucket.sh "$CONFIG_BRANCH" "$CONFIG_REPO_URL" "$CONFIG_REPO_DIR"

echo "Pulling latest source repo..."
/home/ec2-user/naxent-deploy/scripts/www.naxent.in/get-latest-from-bitbucket.sh "$BRANCH" "$REPO_URL" "$REPO_DIR"

# ========================
# Step 2: Check for Changes
# ========================
cd "$REPO_DIR"
PULL_OUTPUT=$(git pull origin "$BRANCH")
echo "$PULL_OUTPUT"

if echo "$PULL_OUTPUT" | grep -q "Already up to date."; then
  echo "No changes detected. Exiting."
  exit 0
fi

echo "Changes detected. Proceeding with deployment..."

# ========================
# Step 3: Inject Deployment Version
# ========================
echo "Injecting deploy version: $DEPLOY_VERSION"
INDEX_FILE="$SOURCE_DIR/index.html"
if [ -f "$INDEX_FILE" ]; then
  sed -i "/<!-- Deployed:/d" "$INDEX_FILE"
  sed -i "/<\/body>/i <!-- Deployed: $DEPLOY_VERSION -->" "$INDEX_FILE"
fi

# ========================
# Step 4: Cache Busting
# ========================
echo "Cache busting using version $VERSION"
find "$SOURCE_DIR" -type f -name "*.html" | while read -r file; do
  sed -i -E "s/(\.js)(\?v=[0-9]+)?([\"'>#])/\\1?v=$VERSION\\3/g" "$file"
  sed -i -E "s/(\.css)(\?v=[0-9]+)?([\"'>#])/\\1?v=$VERSION\\3/g" "$file"
done

# ========================
# Step 5: Upload to S3
# ========================
/home/ec2-user/naxent-deploy/scripts/www.naxent.in/upload-to-s3-bucket.sh "$SOURCE_DIR" "$BUCKET_NAME"

# ========================
# Step 6: Invalidate CloudFront Cache
# ========================
/home/ec2-user/naxent-deploy/scripts/www.naxent.in/clear-cloudfront-cache.sh "$DISTRIBUTION_ID"

# ========================
# Step 7: Final Summary
# ========================
echo "Deployment Completed Successfully!"
echo "==============================="
echo "Version     : $DEPLOY_VERSION"
echo "Website URL : $SITE_URL"
echo "CloudFront  : $DISTRIBUTION_ID"
echo "==============================="

# ========================
# Step 8: Check Live Status
# ========================
curl -I "$SITE_URL"


