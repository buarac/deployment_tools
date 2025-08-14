#!/bin/bash

# Script de déploiement universel
# Usage: ./scripts/deploy-universal.sh [ENV] [VERSION] [PROJECT_DIR]
# 
# ENV: dev|staging|prod (défaut: dev)
# VERSION: tag de version ou "latest" (défaut: latest)
# PROJECT_DIR: chemin vers le projet (défaut: répertoire courant)

set -e  # Exit on error

# Configuration
ENV=${1:-"dev"}
VERSION=${2:-"latest"}
PROJECT_DIR=${3:-$(pwd)}
DEPLOY_TOOLS_DIR=$(dirname $(dirname $(realpath $0)))

# Validation de l'environnement
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo "❌ Environnement invalide: $ENV"
    echo "Environnements supportés: dev, staging, prod"
    exit 1
fi

# Charger les variables d'environnement du projet si disponibles
cd "$PROJECT_DIR"
if [ -f ".env" ]; then
    echo "📋 Chargement des variables depuis .env..."
    set -a  # Auto-export des variables
    source .env
    set +a  # Désactiver auto-export
fi

# Variables dynamiques
APP_NAME=${APP_NAME:-"app-$ENV"}
DEPLOY_USER=${DEPLOY_USER:-$(whoami)}
# Pour PM2, utiliser APP_VERSION du .env si disponible, sinon le paramètre VERSION
PM2_VERSION=${APP_VERSION:-$VERSION}

echo "🚀 Déploiement $ENV - Version: $VERSION"
echo "📁 Projet: $PROJECT_DIR"
echo "🛠️  Outils: $DEPLOY_TOOLS_DIR"
echo ""

# Aller dans le répertoire du projet
cd "$PROJECT_DIR"

# Fonction pour le déploiement dev (local)
deploy_dev() {
    echo "🔧 Mode développement"
    
    # Installer les dépendances si nécessaire
    if [ ! -d "node_modules" ]; then
        echo "📦 Installation des dépendances..."
        npm install
    fi
    
    # Copier le template d'environnement si nécessaire
    if [ ! -f ".env.local" ]; then
        echo "📋 Création de .env.local depuis le template..."
        cp "$DEPLOY_TOOLS_DIR/templates/.env.dev.template" ".env.local"
        echo "⚠️  Configurez .env.local avec vos vraies valeurs !"
    fi
    
    # Créer le dossier logs
    mkdir -p ./logs
    
    # Démarrer avec PM2
    echo "🌟 Démarrage avec PM2..."
    APP_NAME="$APP_NAME" PROJECT_DIR="$PROJECT_DIR" APP_VERSION="$PM2_VERSION" \
        pm2 start "$DEPLOY_TOOLS_DIR/environments/dev/pm2.config.js"
}

# Fonction pour le déploiement staging/prod
deploy_remote() {
    local env_name=$1
    
    echo "🏗️  Mode $env_name"
    
    # Vérifier les variables d'environnement
    env_file=".env.$env_name"
    if [ ! -f "$env_file" ]; then
        echo "⚠️  Création de $env_file depuis le template..."
        cp "$DEPLOY_TOOLS_DIR/templates/.env.$env_name.template" "$env_file"
        echo "❌ ATTENTION: Configurez $env_file avec vos vraies valeurs !"
        echo "Puis relancez le déploiement."
        exit 1
    fi
    
    # Si c'est un build de CI/CD (artifact)
    if [ "$VERSION" != "latest" ] && [ "$VERSION" != "dev" ]; then
        echo "📦 Téléchargement de l'artifact version $VERSION..."
        REPO=${REPO:-"user/project"}
        wget -O build.tar.gz "https://github.com/$REPO/releases/download/$VERSION/build.tar.gz"
        
        echo "🧹 Nettoyage et extraction..."
        rm -rf .next node_modules package.json package-lock.json
        tar -xzf build.tar.gz
        rm build.tar.gz
        
        echo "📦 Installation des dépendances de production..."
        npm ci --production
    fi
    
    # Migrations de base de données
    if [ -f "prisma/schema.prisma" ]; then
        echo "🗃️ Migrations de base de données..."
        cp "$env_file" .env
        npx prisma migrate deploy
        rm .env
    fi
    
    # Créer le dossier logs
    mkdir -p ./logs
    
    # Arrêter l'application existante
    pm2 delete "$APP_NAME" 2>/dev/null || echo "ℹ️  Application $APP_NAME n'était pas en cours d'exécution"
    
    # Démarrer l'application
    echo "🌟 Démarrage avec PM2..."
    APP_NAME="$APP_NAME" PROJECT_DIR="$PROJECT_DIR" APP_VERSION="$PM2_VERSION" \
        pm2 start "$DEPLOY_TOOLS_DIR/environments/$env_name/pm2.config.js"
}

# Vérifier PM2
if ! command -v pm2 &> /dev/null; then
    echo "⚠️  PM2 n'est pas installé. Installation..."
    npm install -g pm2
fi

# Déploiement selon l'environnement
case $ENV in
    "dev")
        deploy_dev
        ;;
    "staging"|"prod")
        deploy_remote $ENV
        ;;
esac

# Sauvegarder la configuration PM2
pm2 save

# Configurer le démarrage automatique (prod uniquement)
if [ "$ENV" = "prod" ]; then
    if ! pm2 startup | grep -q "already"; then
        echo "🔧 Configuration du démarrage automatique PM2..."
        pm2 startup systemd -u $DEPLOY_USER --hp /home/$DEPLOY_USER
    fi
fi

# Afficher le statut
echo ""
echo "✅ Déploiement $ENV terminé !"
echo "📊 Version déployée: $VERSION"
echo ""
echo "🔍 Statut PM2:"
pm2 list
echo ""
echo "📋 Commandes utiles:"
echo "  pm2 list                    # Liste des apps"
echo "  pm2 logs $APP_NAME          # Voir les logs"
echo "  pm2 restart $APP_NAME       # Redémarrer"
echo "  pm2 stop $APP_NAME          # Arrêter"
echo "  pm2 monit                   # Interface de monitoring"
echo ""

# Test de santé
if [ "$ENV" != "dev" ]; then
    PORT=$(grep "PORT=" "$env_file" | cut -d= -f2)
    echo "🌐 Test de santé: curl http://localhost:$PORT/api/health"
fi