#!/bin/bash
set -euo pipefail

# ========================
# Bitbucket Naxent-Deploy-Repo Config
# ========================
export CONFIG_REPO_URL="https://pandiang@bitbucket.org/vanavilincteam/naxent-deploy.git"
export CONFIG_REPO_DIR="/home/ec2-user/naxent-deploy/scripts/www.naxent.in"
export CONFIG_BRANCH="main"

# ========================
# Bitbucket Naxent-Source-Repo Config
# ========================
export REPO_URL="https://pandiang@bitbucket.org/vanavilincteam/www.naxent.in.git"
export REPO_DIR="/home/ec2-user/work/www.naxent.in"
export BRANCH="main"

# ========================
# AWS Config
# ========================
export BUCKET_NAME="test.naxent.in"
export DISTRIBUTION_ID="E3MZBZ63III0G3"

# ========================
# Project Build Path
# ========================
export SOURCE_DIR="$REPO_DIR/naxent/build/naxent-static"

# ========================
# Auto-generated Deployment Info
# ========================
export VERSION=$(date -u +%Y%m%d%H%M%S)
export DEPLOY_VERSION="v1.0.0 - $VERSION"
export SITE_URL="https://$BUCKET_NAME"