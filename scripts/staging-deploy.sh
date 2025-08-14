#!/bin/bash

# Script de déploiement staging
# Usage: ./scripts/staging-deploy.sh [VERSION] [PROJECT_DIR]

SCRIPT_DIR=$(dirname $(realpath $0))
VERSION=${1:-"latest"}
PROJECT_DIR=${2:-$(pwd)}

echo "🚀 Déploiement en staging..."
"$SCRIPT_DIR/deploy-universal.sh" staging "$VERSION" "$PROJECT_DIR"