#!/bin/bash

# Script de déploiement production
# Usage: ./scripts/prod-deploy.sh [VERSION] [PROJECT_DIR]

SCRIPT_DIR=$(dirname $(realpath $0))
VERSION=${1:-"latest"}
PROJECT_DIR=${2:-$(pwd)}

echo "🏭 Déploiement en production..."
"$SCRIPT_DIR/deploy-universal.sh" prod "$VERSION" "$PROJECT_DIR"