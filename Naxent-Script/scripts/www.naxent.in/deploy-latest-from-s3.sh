#!/bin/bash
set -euo pipefail

# ========================
# STEP 1: Load Environment
# ========================
ENV="$1"

if [ -z "$ENV" ]; then
  echo "Usage: $0 [test|development|production]"
  exit 1
fi

ENV_PATH="/home/ec2-user/work/naxent-config/$ENV/environment.sh"


if [ ! -f "$ENV_PATH" ]; then
  echo "Environment file not found: $ENV_PATH"
  exit 1
fi

echo "Loading environment: $ENV"
source "$ENV_PATH"


# ========================
# STEP 1: Pull latest deployment script from naxent-config
# ========================
if [ ! -d "$CONFIG_REPO_DIR" ]; then
  echo "Cloning naxent-config repo..."
  git clone "$CONFIG_REPO_URL" "$CONFIG_REPO_DIR"
else
  echo "Pulling latest updates from naxent-config..."
  cd "$CONFIG_REPO_DIR" || exit 1
  git checkout "$CONFIG_BRANCH"
  git pull origin "$CONFIG_BRANCH"
  echo "naxent-config pull successfully"
fi


# ========================
# STEP 2: Deploy Website
# ========================
# Clone the website repo (if needed)
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning website repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1

# Ensure branch is checked out and clean
echo "Checking out $BRANCH and resetting to match remote..."
git checkout "$BRANCH"
git reset --hard

PULL_OUTPUT=$(git pull --rebase origin "$BRANCH")

echo "$PULL_OUTPUT"

if echo "$PULL_OUTPUT" | grep -q "Already up to date."; then
  echo "No new changes. Skipping deployment."
  exit 0
fi

echo "Changes detected. Proceeding with deployment..."


# ========================
# Deployment Metadata
# ========================
VERSION=$(date -u +%Y%m%d%H%M%S)
DEPLOY_VERSION="v1.0.0 - $VERSION"
SITE_URL="https://$BUCKET_NAME"


# Inject deployment version into index.html
sed -i "/<!-- Deployed:/d" "$SOURCE_DIR/index.html"
sed -i "/<\/body>/i <!-- Deployed: $DEPLOY_VERSION -->" "$SOURCE_DIR/index.html"

# Cache busting
echo "Applying cache busting with version $VERSION..."
find "$SOURCE_DIR" -type f -name "*.html" | while read -r file; do
  sed -i -E "s/(\.js)(\?v=[0-9]+)?([\"'>#])/\\1?v=$VERSION\\3/g" "$file"
  sed -i -E "s/(\.css)(\?v=[0-9]+)?([\"'>#])/\\1?v=$VERSION\\3/g" "$file"
  # GA Tag Replacement - only for production
  echo "Replacing GA tag in: $file"
  sed -i "s/$OLD_GA_TAG/$GA_TAG/g" "$file"
done


# ================================
# Update Sitemap URLs
# ================================
echo "Updating sitemap.xml URLs to absolute paths at $SITEMAP_PATH..."

# Show before update (first 3 URL lines)
echo "[Before] sitemap.xml URLs:"
grep '<loc>' "$SITEMAP_PATH" | head -3

# Run replacement to make all <loc> entries absolute
#sed -i "s|<loc><!\[CDATA\[/|<loc><![CDATA[https://$BUCKET_NAME/|g" "$SITEMAP_PATH"
sed -i "s|<loc><![CDATA\[/|<loc><![CDATA[https://$BUCKET_NAME/|g" "$SITEMAP_PATH"

# Show after update (first 3 URL lines)
echo "[After] sitemap.xml URLs:"
grep '<loc>' "$SITEMAP_PATH" | head -3


# ================================
# Set correct robots.txt
# ================================
echo "[INFO] Setting robots.txt for $ENV environment..."

if [ -f "$ROBOTS_TXT_SOURCE" ]; then
  cp "$ROBOTS_TXT_SOURCE" "$ROBOTS_TXT_DEST/robots.txt"
  echo "[INFO] robots.txt copied from $ROBOTS_TXT_SOURCE to $ROBOTS_TXT_DEST"
else
  echo "[ERROR] robots.txt not found for $ENV"
  exit 1
fi


# ========================
# Clean up old files in S3 bucket
# ========================
echo "Removing all files from S3 bucket: $BUCKET_NAME"
aws s3 rm "s3://$BUCKET_NAME" --recursive
echo "S3 Delete complete"


# ========================
# Upload new files to S3
# ========================
echo "Uploading files from ${SOURCE_DIR} to S3 bucket: ${BUCKET_NAME}"
aws s3 sync "$SOURCE_DIR" "s3://$BUCKET_NAME"
echo "S3 Upload complete"


# CloudFront invalidation
echo "Triggering CloudFront invalidation..."
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

# Final summary
echo "===================================="
echo "Deployment Completed Successfully!"
echo "Version     : $DEPLOY_VERSION"
echo "Website URL : $SITE_URL"
echo "CloudFront  : $DISTRIBUTION_ID"
echo "===================================="

# Check live
curl -I "$SITE_URL"