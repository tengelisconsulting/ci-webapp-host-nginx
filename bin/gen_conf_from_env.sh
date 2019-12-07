#!/bin/sh

if [ "${NGINX_PORT}" = "" ]; then
    echo "ERR - Supply NGINX_PORT"
    exit 1
fi

if [ "${BUILD_MGR_PORT}" = "" ]; then
    echo "ERR - Supply BUILD_MGR_PORT"
    exit 1
fi

if [ "${BUILD_MGR_HOST}" = "" ]; then
    echo "ERR - Supply BUILD_MGR_HOST"
    exit 1
fi

cat << EOF
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        '' close;
    }

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    gzip  on;

    server {
        listen       ${NGINX_PORT};
        server_name  nginx;

        client_max_body_size 100M;

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }

        location / {
            root   /usr/share/nginx/html;
            try_files \$uri \$uri/ @staticindex;
        }

        location /dev {
          root   /usr/share/nginx/html;
          proxy_pass http://${BUILD_MGR_HOST}:${BUILD_MGR_PORT};
        }

        location @staticindex {
            add_header Cache-Control no-cache;
            expires 0;
            try_files /index.html =404;
        }

    }
}
EOF
