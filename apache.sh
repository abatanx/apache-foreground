#!/bin/sh
# =======================================================================
#  Standalone HTTPd + PHP7.x + Xdebug on foreground process for HomeBrew
# =======================================================================
# brew install apache
# brew install php@7.4
# pecl install xdebug
# ========================================================

# ========================================================
cd $(dirname $0)
. ./config.conf
# ========================================================
ABS_DOCUMENT_ROOT=$(cd ${DOCUMENT_ROOT} && pwd)
ABS_ROOT=$(pwd)

trap 'echo "Received SIGTERM"; echo "!!! If you want to stop httpd, press CTRL + C in succession."; sleep 1' 15

echo "... Spawning httpd in foreground ..."
while true
do
  env \
    APACHE_SERVER_PORT=${SERVER_PORT} \
    APACHE_SERVER_NAME=${SERVER_NAME} \
    APACHE_DOCUMENT_ROOT=${ABS_DOCUMENT_ROOT} \
    APACHE_SCRIPT_ROOT=${ABS_ROOT} \
    APACHE_PID_FILE=${ABS_ROOT}/httpd.pid \
    PHP7_MODULE_PATH=${PHP7_MODULE_PATH} \
    PHP_INCLUDE_PATH=${PHP_INCLUDE_PATH} \
    XDEBUG2=${XDEBUG2} \
    XDEBUG2_REMOTE_HOST=${XDEBUG2_REMOTE_HOST} \
    XDEBUG2_REMOTE_PORT=${XDEBUG2_REMOTE_PORT} \
    XDEBUG2_IDEKEY=${XDEBUG2_IDEKEY} \
    XDEBUG3=${XDEBUG3} \
    XDEBUG3_CLIENT_HOST=${XDEBUG3_CLIENT_HOST} \
    XDEBUG3_CLIENT_PORT=${XDEBUG3_CLIENT_PORT} \
    XDEBUG3_IDEKEY=${XDEBUG3_IDEKEY} \
    httpd -f ${ABS_ROOT}/etc/httpd.conf -DFOREGROUND | perl ./etc/apache-logfilter.pl
  echo "... Respawning httpd in foreground ..."
done
