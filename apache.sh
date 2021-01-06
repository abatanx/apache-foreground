#!/bin/sh

# ========================================================
# brew install apache
# brew install php7.4
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
    httpd -f ${ABS_ROOT}/etc/httpd.conf -DFOREGROUND | perl ./etc/apache-logfilter.pl
  echo "... Respawning httpd in foreground ..."
done
