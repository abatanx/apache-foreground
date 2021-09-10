#!/bin/sh
# ===========================================================================
#  Standalone HTTPd + PHP7.4/8.0 + Xdebug on foreground process for HomeBrew
# ===========================================================================
# brew install apache
# brew install php@7.4
# brew install php@8.0
# pecl install xdebug
# ========================================================

# ========================================================
cd $(dirname $0)
. ./config.conf
# ========================================================
ABS_DOCUMENT_ROOT=$(cd ${DOCUMENT_ROOT} && pwd)
ABS_ROOT=$(pwd)
# ========================================================
APACHE_PID_FILE=${ABS_ROOT}/httpd.pid
APACHE_IGNORE_REBOOT=${ABS_ROOT}/__stop_httpd__
# ========================================================
HTTPD_ENV=""
if [ "$XDEBUG" = "3" ]
then
  HTTPD_ENV="XDEBUG_MODE=debug"
fi

/bin/rm $APACHE_IGNORE_REBOOT

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
    PHP_MODULE_PATH=${PHP_MODULE_PATH} \
    PHP_APACHE_MODULE_KEY=${PHP_APACHE_MODULE_KEY} \
    XDEBUG=${XDEBUG} \
    XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST} \
    XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT} \
    XDEBUG_IDEKEY=${XDEBUG_IDEKEY} \
    $HTTPD_ENV \
    httpd -f ${ABS_ROOT}/etc/httpd.conf -DFOREGROUND | perl ./etc/apache-logfilter.pl
  if [ -f $APACHE_IGNORE_REBOOT ]
  then
	/bin/rm $APACHE_IGNORE_REBOOT
    break
  fi

  echo "... Respawning httpd in foreground ..."
done
