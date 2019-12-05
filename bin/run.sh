#!/bin/sh

/app/bin/gen_conf_from_env.sh > /etc/nginx/nginx.conf \
    && nginx -g "daemon off;"
