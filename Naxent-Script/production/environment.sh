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

# ========================
# AWS Config
# ========================
export BUCKET_NAME="www.naxent.in"
export DISTRIBUTION_ID="E3MGK3P23F8JZQ"


# ========================
# GA Tag ID
# ========================
export OLD_GA_TAG="G-QBXMT37PDC"
export GA_TAG="G-79YL6JT5SE"


# ========================
# Project Build Path
# ========================
export SOURCE_DIR="$REPO_DIR/naxent/build/naxent-static"
