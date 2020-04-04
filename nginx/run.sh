#!/bin/sh
#
# configuration nginx
#
#
set -e

SED_REPLACE=`env | sed -e 's#\([^=]*\)=\(.*\)\s*$#s\#<\1>\#\2\#g;#'| tr '\n' ' ' | sed 's/$/\n/'`

[ -z "${APP_NAME}" -o -z "${API_PATH}" -o -z "${BACKEND_HOST}" -o -z "${BACKEND_PORT}" ] && echo "missing some env var" && exit 1

(
 cat /etc/nginx/conf.d/default.template | \
 sed "${SED_REPLACE}" | \
 sed "/^server {/a\
error_log /dev/stderr warn;\
access_log /dev/stdout main;
" > /etc/nginx/conf.d/default.conf
sed "${SED_REPLACE}" < /etc/nginx/nginx.template > /etc/nginx/nginx.conf
) && echo "nginx conf:" && cat /etc/nginx/nginx.conf && echo "default conf:" && cat /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"
