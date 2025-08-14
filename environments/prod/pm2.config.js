module.exports = {
  apps: [{
    name: process.env.APP_NAME || 'app-prod',
    script: 'npm',
    args: 'run start',
    cwd: process.env.PROJECT_DIR || process.cwd(),
    instances: 'max', // Utilise tous les CPU disponibles
    exec_mode: 'cluster',
    version: process.env.APP_VERSION || 'production',
    
    // Variables d'environnement - Production
    env: {
      NODE_ENV: 'production',
      PORT: process.env.PROD_PORT || 3002,
      DATABASE_URL: process.env.PROD_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_prod'
    },
    
    // Fichier d'environnement
    env_file: '.env.production',
    
    // Logs
    log_file: 'logs/prod.log',
    out_file: 'logs/prod-out.log',
    error_file: 'logs/prod-error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    
    // Configuration production
    watch: false,
    max_restarts: 15,
    min_uptime: '30s',
    max_memory_restart: '500M',
    
    // Configuration avancée
    kill_timeout: 10000,
    wait_ready: true,
    listen_timeout: 15000,
    
    // Monitoring et performance
    monitoring: true,
    pmx: true,
    
    // Gestion des erreurs
    autorestart: true,
    restart_delay: 4000
  }]
}