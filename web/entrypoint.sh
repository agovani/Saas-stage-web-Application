#!/bin/sh
set -eu
: "${BASIC_AUTH_USER:=admin}"
: "${BASIC_AUTH_PASS:=changeme}"
htpasswd_file=/etc/nginx/.htpasswd
apk add --no-cache apache2-utils >/dev/null 2>&1 || true
htpasswd -bc "$htpasswd_file" "$BASIC_AUTH_USER" "$BASIC_AUTH_PASS"
exec nginx -g 'daemon off;'
