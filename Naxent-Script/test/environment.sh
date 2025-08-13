#!/bin/bash

# ========================
# Bitbucket Naxent-Config-Repo Config
# ========================
export CONFIG_REPO_URL="https://pandiang@bitbucket.org/vanavilincteam/naxent-config.git"
export CONFIG_REPO_DIR="/home/ec2-user/work/naxent-config/scripts/www.naxent.in"
export CONFIG_BRANCH="main"

# ========================
# Bitbucket Naxent-Source-Repo Config
# ========================
export REPO_URL="https://pandiang@bitbucket.org/vanavilincteam/www.naxent.in.git"
export REPO_DIR="/home/ec2-user/work/www.naxent.in"
export BRANCH="main"


# ========================
# Robots.txt Config
# ========================
ROBOTS_TXT_SOURCE="/home/ec2-user/work/naxent-config/$ENV/robots.txt"
ROBOTS_TXT_DEST="$REPO_DIR/naxent/build/naxent-static"


# ================================
# Sitemap.xml Absolute URL Config
# ================================
SITEMAP_PATH="$REPO_DIR/naxent/build/naxent-static/sitemap.xml"


# ========================
# AWS Config
# ========================
export BUCKET_NAME="test.naxent.in"
export DISTRIBUTION_ID="E3MZBZ63III0G3"


# ========================
# GA Tag ID
# ========================
export OLD_GA_TAG="G-QBXMT37PDC"
export GA_TAG="G-TAGCHECK123"


# ========================
# Project Build Path
# ========================
export SOURCE_DIR="$REPO_DIR/naxent/build/naxent-static"
