#!/bin/sh
# WARNING: This script will reset the current git branch to match the remote branch and pull the latest changes. Any local changes will be lost.
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"
git fetch origin
git reset --hard "origin/$current_branch"
git pull origin "$current_branch"
echo "Branch $current_branch has been reset and updated."