module.exports = {
  apps: [{
    name: process.env.APP_NAME || 'app-dev',
    script: 'npm',
    args: 'run dev',
    cwd: process.env.PROJECT_DIR || process.cwd(),
    instances: 1,
    exec_mode: 'fork',
    version: process.env.APP_VERSION || 'dev',
    
    // Variables d'environnement - Développement
    env: {
      NODE_ENV: 'development',
      PORT: process.env.DEV_PORT || 3000,
      DATABASE_URL: process.env.DEV_DATABASE_URL || 'postgresql://user:pass@localhost/myapp_dev'
    },
    
    // Fichier d'environnement
    env_file: '.env.local',
    
    // Logs
    log_file: 'logs/dev.log',
    out_file: 'logs/dev-out.log',
    error_file: 'logs/dev-error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Configuration développement
    watch: true,
    ignore_watch: ['node_modules', '.git', 'logs', '.next'],
    max_restarts: 5,
    min_uptime: '5s',
    max_memory_restart: '300M',
    
    // Configuration avancée
    kill_timeout: 3000,
    wait_ready: false,
    
    // Monitoring
    monitoring: true
  }]
}