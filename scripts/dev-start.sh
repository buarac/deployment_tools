#!/bin/bash

# Script de démarrage développement
# Usage: ./scripts/dev-start.sh [PROJECT_DIR]

SCRIPT_DIR=$(dirname $(realpath $0))
PROJECT_DIR=${1:-$(pwd)}

echo "🔧 Démarrage en mode développement..."
"$SCRIPT_DIR/deploy-universal.sh" dev latest "$PROJECT_DIR"