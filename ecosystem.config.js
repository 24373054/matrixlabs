module.exports = {
  apps: [{
    name: 'matrixlab-exchange',
    script: './server.js',
    cwd: '/home/ubuntu/yz/Web3/网站test1',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3104
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
