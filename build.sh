#!/bin/bash
set -e

IMAGE_NAME="devcontainer-sky"
IMAGE_TAG="latest"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building ${IMAGE_NAME}:${IMAGE_TAG}..."
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "$SCRIPT_DIR"

echo "Done. Image tagged as ${IMAGE_NAME}:${IMAGE_TAG}"