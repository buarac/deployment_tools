module.exports = {
  apps: [{
    name: process.env.APP_NAME || 'app-staging',
    script: 'npm',
    args: 'run start',
    cwd: process.env.PROJECT_DIR || process.cwd(),
    instances: 1,
    exec_mode: 'fork',
    version: process.env.APP_VERSION || 'staging',
    
    // Variables d'environnement - Staging
    env: {
      NODE_ENV: 'production',
      PORT: process.env.STAGING_PORT || 3001,
      DATABASE_URL: process.env.STAGING_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_staging'
    },
    
    // Fichier d'environnement
    env_file: '.env.staging',
    
    // Logs
    log_file: 'logs/staging.log',
    out_file: 'logs/staging-out.log',
    error_file: 'logs/staging-error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Configuration staging
    watch: false,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '400M',
    
    // Configuration avancée
    kill_timeout: 5000,
    wait_ready: true,
    listen_timeout: 10000,
    
    // Monitoring
    monitoring: true
  }]
}