module.exports = {
  apps: [{
    name: process.env.APP_NAME || 'nextjs-template',
    script: 'npm',
    args: 'run start',
    cwd: process.env.APP_CWD || `/home/${process.env.DEPLOY_USER || 'buarac'}/app/nextjs_template/scripts/myapp`,
    instances: 1,
    exec_mode: 'fork',
    version: process.env.APP_VERSION || 'unknown',
    
    // Variables d'environnement - Scratch (développement)
    env: {
      NODE_ENV: 'development',
      PORT: 3000,
      DATABASE_URL: process.env.SCRATCH_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_scratch'
    },
    
    // Variables d'environnement - Staging (pré-production)
    env_staging: {
      NODE_ENV: 'production',
      PORT: 3001,
      DATABASE_URL: process.env.STAGING_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_staging'
    },
    
    // Variables d'environnement - Stable (production)
    env_stable: {
      NODE_ENV: 'production',
      PORT: 3002,
      DATABASE_URL: process.env.STABLE_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_stable'
    },
    
    // Fichier d'environnement
    env_file: '.env.production',
    
    // Logs
    log_file: 'logs/app.log',
    out_file: 'logs/out.log',
    error_file: 'logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Redémarrage automatique
    watch: false,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '500M',
    
    // Configuration avancée
    kill_timeout: 5000,
    wait_ready: true,
    listen_timeout: 10000,
    
    // Monitoring
    monitoring: true
  }]
}