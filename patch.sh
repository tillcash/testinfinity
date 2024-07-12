#!/bin/bash

set -e  # Exit script immediately if any command exits with a non-zero status

# Base URLs for GitHub and GitHub API
BASE_URL="https://github.com/"
API_BASE_URL="https://api.github.com/repos/"

# Repositories
REPO_CLI="ReVanced/revanced-cli"
REPO_PATCHES="ReVanced/revanced-patches"
REPO_INTEGRATIONS="ReVanced/revanced-integrations"
REPO_INFINITY="Docile-Alligator/Infinity-For-Reddit"

# Function to fetch the latest release version from GitHub API
get_latest_version() {
    local repo="$1"
    curl "${API_BASE_URL}${repo}/releases/latest" | jq -r '.tag_name'
}

# "Fetch latest versions from respective repositories"
CLI_VERSION=$(get_latest_version "$REPO_CLI")
PATCHES_VERSION=$(get_latest_version "$REPO_PATCHES")
INTEGRATIONS_VERSION=$(get_latest_version "$REPO_INTEGRATIONS")
INFINITY_VERSION=$(get_latest_version "$REPO_INFINITY")

# Special case: adjust Infinity version if needed
if [[ "${INFINITY_VERSION}" == "v7.2.9" ]]; then
    INFINITY_VERSION="v7.2.8"
fi

# Download artifacts from GitHub releases
curl -sLo "revanced-cli.jar" "${BASE_URL}${REPO_CLI}/releases/download/${CLI_VERSION}/revanced-cli-${CLI_VERSION#v}-all.jar"
curl -sLo "revanced-patches.jar" "${BASE_URL}${REPO_PATCHES}/releases/download/${PATCHES_VERSION}/revanced-patches-${PATCHES_VERSION#v}.jar"
curl -sLo "revanced-integrations.apk" "${BASE_URL}${REPO_INTEGRATIONS}/releases/download/${INTEGRATIONS_VERSION}/revanced-integrations-${INTEGRATIONS_VERSION#v}.apk"
curl -sLo "infinity.apk" "${BASE_URL}${REPO_INFINITY}/releases/download/${INFINITY_VERSION}/Infinity-${INFINITY_VERSION}.apk"

ls -lh

# Patch with ReVanced CLI
java -jar revanced-cli.jar patch \
    -b revanced-patches.jar \
    -m revanced-integrations.apk \
    --keystore=revanced.keystore \
    --options=options.json \
    --out=Re-Infinity-${INFINITY_VERSION}.apk \
    infinity.apk

# Check if the patching was successful
if [ $? -ne 0 ]; then
    echo "Error: Patching failed."
    exit 1
fi

# Optionally, perform additional checks or actions here

# Exit script successfully
exit 0
