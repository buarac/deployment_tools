# Guide d'utilisation - Deployment Tools

## Vue d'ensemble

Les outils de déploiement permettent de gérer facilement plusieurs environnements (dev, staging, prod) pour vos applications Next.js avec PM2.

## Structure des fichiers

```
deployment_tools/
├── environments/           # Configurations par environnement
│   ├── dev/               # Développement local
│   ├── staging/           # Pré-production
│   └── prod/              # Production
├── scripts/               # Scripts de déploiement
│   ├── deploy-universal.sh    # Script principal
│   ├── dev-start.sh          # Démarrage dev
│   ├── staging-deploy.sh     # Déploiement staging
│   ├── prod-deploy.sh        # Déploiement production
│   └── pm2-manager.sh        # Gestionnaire PM2
├── templates/             # Templates de configuration
│   ├── .env.dev.template
│   ├── .env.staging.template
│   └── .env.prod.template
└── docs/                  # Documentation
```

## Installation

### Prérequis

- Node.js et npm installés
- PM2 installé globalement : `npm install -g pm2`

### Configuration

1. **Cloner ou copier les outils de déploiement** dans votre projet ou séparément
2. **Configurer les variables d'environnement** pour chaque environnement

## Utilisation

### 1. Développement local

```bash
# Depuis votre projet Next.js
/path/to/deployment_tools/scripts/dev-start.sh

# Ou en spécifiant le répertoire du projet
/path/to/deployment_tools/scripts/dev-start.sh /path/to/your/project
```

**Ce que fait ce script :**
- Installe les dépendances si nécessaire
- Crée `.env.local` depuis le template si inexistant
- Démarre l'app en mode watch avec PM2
- Port par défaut : 3000

### 2. Déploiement Staging

```bash
# Déploiement depuis un artifact GitHub
/path/to/deployment_tools/scripts/staging-deploy.sh v1.0.0

# Déploiement local (développement)
/path/to/deployment_tools/scripts/staging-deploy.sh latest /path/to/project
```

**Ce que fait ce script :**
- Télécharge l'artifact si version spécifiée
- Crée `.env.staging` depuis le template si inexistant
- Exécute les migrations Prisma
- Démarre l'app en mode production
- Port par défaut : 3001

### 3. Déploiement Production

```bash
# Déploiement depuis un artifact GitHub
/path/to/deployment_tools/scripts/prod-deploy.sh v1.0.0

# ATTENTION: Ne jamais déployer en prod sans version spécifique !
```

**Ce que fait ce script :**
- Télécharge l'artifact obligatoirement
- Vérifie `.env.production`
- Exécute les migrations Prisma
- Démarre en mode cluster (tous les CPU)
- Configure le démarrage automatique
- Port par défaut : 3002

### 4. Gestion des applications avec PM2

```bash
# Voir le statut de toutes les applications
/path/to/deployment_tools/scripts/pm2-manager.sh status

# Redémarrer une application spécifique
/path/to/deployment_tools/scripts/pm2-manager.sh restart dev
/path/to/deployment_tools/scripts/pm2-manager.sh restart staging
/path/to/deployment_tools/scripts/pm2-manager.sh restart prod

# Arrêter une application
/path/to/deployment_tools/scripts/pm2-manager.sh stop staging

# Voir les logs
/path/to/deployment_tools/scripts/pm2-manager.sh logs prod

# Interface de monitoring
/path/to/deployment_tools/scripts/pm2-manager.sh monit

# Supprimer une application
/path/to/deployment_tools/scripts/pm2-manager.sh delete dev
```

## Configuration des environnements

### Variables d'environnement personnalisées

Vous pouvez surcharger les variables par défaut :

```bash
# Personnaliser le nom de l'application
export APP_NAME="mon-app-prod"

# Personnaliser les ports
export DEV_PORT=4000
export STAGING_PORT=4001  
export PROD_PORT=4002

# Pour les artifacts GitHub
export REPO="username/repository"
```

### Fichiers .env

Chaque environnement utilise son propre fichier `.env` :

- **dev** : `.env.local` (créé automatiquement depuis le template)
- **staging** : `.env.staging` (à configurer manuellement)
- **prod** : `.env.production` (à configurer manuellement)

## Workflows recommandés

### Développement local

1. `dev-start.sh` pour démarrer l'environnement de dev
2. Modifier le code (rechargement automatique avec watch)
3. `pm2-manager.sh stop dev` pour arrêter quand terminé

### Déploiement staging

1. Créer une release GitHub avec artifact
2. `staging-deploy.sh v1.x.x` pour déployer
3. Tester l'application sur le port staging
4. `pm2-manager.sh logs staging` pour vérifier les logs

### Déploiement production

1. Valider en staging
2. `prod-deploy.sh v1.x.x` pour déployer en production
3. `pm2-manager.sh status` pour vérifier le cluster
4. Surveiller avec `pm2-manager.sh monit`

## Résolution de problèmes

### Application qui ne démarre pas

```bash
# Vérifier les logs
pm2 logs app-[env]

# Redémarrer
./pm2-manager.sh restart [env]
```

### Problème de base de données

```bash
# Réexécuter les migrations manuellement
cd /path/to/project
cp .env.[env] .env
npx prisma migrate deploy
rm .env
```

### Nettoyer complètement

```bash
# Supprimer toutes les applications PM2
./pm2-manager.sh delete all
pm2 flush  # Nettoyer les logs
pm2 save   # Sauvegarder l'état vide
```

## Personnalisation avancée

### Modifier les configurations PM2

Éditez les fichiers dans `environments/[env]/pm2.config.js` pour personnaliser :
- Nombre d'instances
- Limites mémoire
- Configuration des logs
- Variables d'environnement spécifiques

### Ajouter un nouvel environnement

1. Créer `environments/nouvel-env/pm2.config.js`
2. Créer `templates/.env.nouvel-env.template`
3. Modifier `deploy-universal.sh` pour inclure le nouvel environnement