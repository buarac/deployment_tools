#!/bin/bash

# Gestionnaire PM2 pour tous les environnements
# Usage: ./scripts/pm2-manager.sh [COMMAND] [ENV] [APP_NAME]
#
# COMMANDS: start|stop|restart|delete|logs|status|monit
# ENV: dev|staging|prod|all
# APP_NAME: optionnel, déduit de l'environnement

set -e

COMMAND=${1:-"status"}
ENV=${2:-"all"}
APP_NAME_OVERRIDE=$3

# Fonction pour déduire le nom de l'app
get_app_name() {
    local env=$1
    if [ -n "$APP_NAME_OVERRIDE" ]; then
        echo "$APP_NAME_OVERRIDE"
    else
        echo "app-$env"
    fi
}

# Fonction pour exécuter une commande PM2
run_pm2_command() {
    local cmd=$1
    local app_name=$2
    
    case $cmd in
        "start")
            echo "❌ Utilisez les scripts de déploiement pour démarrer les applications"
            ;;
        "stop")
            echo "⏸️  Arrêt de $app_name..."
            pm2 stop "$app_name" 2>/dev/null || echo "⚠️  $app_name n'est pas en cours d'exécution"
            ;;
        "restart")
            echo "🔄 Redémarrage de $app_name..."
            pm2 restart "$app_name" 2>/dev/null || echo "⚠️  $app_name n'est pas en cours d'exécution"
            ;;
        "delete")
            echo "🗑️  Suppression de $app_name..."
            pm2 delete "$app_name" 2>/dev/null || echo "⚠️  $app_name n'existe pas"
            ;;
        "logs")
            echo "📋 Logs de $app_name..."
            pm2 logs "$app_name" --lines 50
            ;;
        *)
            echo "❌ Commande inconnue: $cmd"
            ;;
    esac
}

# Validation de la commande
if [[ ! "$COMMAND" =~ ^(start|stop|restart|delete|logs|status|monit)$ ]]; then
    echo "❌ Commande invalide: $COMMAND"
    echo "Commandes supportées: start, stop, restart, delete, logs, status, monit"
    exit 1
fi

# Commandes globales
case $COMMAND in
    "status")
        echo "📊 Statut de tous les processus PM2:"
        pm2 list
        exit 0
        ;;
    "monit")
        echo "📈 Interface de monitoring PM2..."
        pm2 monit
        exit 0
        ;;
esac

# Traitement par environnement
if [ "$ENV" = "all" ]; then
    echo "🌍 Exécution de '$COMMAND' sur tous les environnements..."
    for env in dev staging prod; do
        app_name=$(get_app_name $env)
        echo ""
        echo "--- Environnement: $env ---"
        run_pm2_command "$COMMAND" "$app_name"
    done
else
    # Validation de l'environnement
    if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
        echo "❌ Environnement invalide: $ENV"
        echo "Environnements supportés: dev, staging, prod, all"
        exit 1
    fi
    
    app_name=$(get_app_name $ENV)
    run_pm2_command "$COMMAND" "$app_name"
fi

# Sauvegarder après modifications
if [[ "$COMMAND" =~ ^(stop|restart|delete)$ ]]; then
    pm2 save
fi

echo ""
echo "📋 Commandes utiles:"
echo "  ./pm2-manager.sh status              # Statut de tous les processus"
echo "  ./pm2-manager.sh stop dev            # Arrêter le développement"
echo "  ./pm2-manager.sh restart prod        # Redémarrer la production"
echo "  ./pm2-manager.sh logs staging        # Voir les logs staging"
echo "  ./pm2-manager.sh monit               # Interface de monitoring"