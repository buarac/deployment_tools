# Deployment Tools

🚀 Outils de déploiement universels pour applications Next.js avec PM2

## ✨ Fonctionnalités

- ✅ **Multi-environnements** : dev, staging, prod
- ✅ **Configuration automatique** PM2 par environnement
- ✅ **Gestion des variables** d'environnement séparées
- ✅ **Scripts unifiés** pour tous les déploiements
- ✅ **Gestion complète PM2** (start, stop, logs, monitoring)
- ✅ **Support CI/CD** avec artifacts GitHub
- ✅ **Templates** de configuration prêts à l'emploi

## 🏗️ Structure

```
deployment_tools/
├── environments/           # Configuration PM2 par environnement
│   ├── dev/pm2.config.js      # Config développement (watch mode)
│   ├── staging/pm2.config.js  # Config staging (single instance)
│   └── prod/pm2.config.js     # Config production (cluster mode)
├── scripts/               # Scripts de déploiement
│   ├── deploy-universal.sh    # ⭐ Script principal universel
│   ├── dev-start.sh          # Raccourci développement
│   ├── staging-deploy.sh     # Raccourci staging
│   ├── prod-deploy.sh        # Raccourci production
│   └── pm2-manager.sh        # Gestionnaire PM2 complet
├── templates/            # Templates variables d'environnement
│   ├── .env.dev.template
│   ├── .env.staging.template
│   └── .env.prod.template
├── configs/              # Anciennes configurations (legacy)
│   └── pm2/ecosystem.config.js
└── docs/                 # Documentation complète
    └── USAGE.md          # 📖 Guide d'utilisation détaillé
```

## 🚀 Démarrage rapide

### 1. Développement local
```bash
./scripts/dev-start.sh /path/to/your/nextjs-project
```

### 2. Déploiement staging
```bash
./scripts/staging-deploy.sh v1.0.0 /path/to/your/nextjs-project
```

### 3. Déploiement production
```bash
./scripts/prod-deploy.sh v1.0.0 /path/to/your/nextjs-project
```

### 4. Gestion PM2
```bash
./scripts/pm2-manager.sh status    # Voir toutes les apps
./scripts/pm2-manager.sh logs dev  # Logs développement
./scripts/pm2-manager.sh monit     # Interface monitoring
```

## 📖 Documentation complète

➡️ **[Guide d'utilisation détaillé](docs/USAGE.md)**

## 🎯 Environnements

| Environnement | Port | Mode PM2 | Fichier env | Usage |
|--------------|------|----------|-------------|-------|
| **dev** | 3000 | fork + watch | `.env.local` | Développement local |
| **staging** | 3001 | fork | `.env.staging` | Tests pré-production |
| **prod** | 3002 | cluster | `.env.production` | Production |

## ⚙️ Configuration

Les templates d'environnement sont copiés automatiquement au premier déploiement. 
Configurez ensuite les vraies valeurs dans les fichiers `.env` de votre projet.

## 🔧 Prérequis

- Node.js et npm
- PM2 : `npm install -g pm2`
- Variables d'environnement configurées pour chaque environnement