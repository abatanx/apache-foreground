#!/bin/sh
# ===========================================================================
#  Standalone HTTPd + PHP7.4/8.0 + Xdebug on foreground process for HomeBrew
# ===========================================================================
# brew install apache
# brew install php@7.4
# brew install php@8.0
# pecl install xdebug
# ========================================================
export PGGSSENCMODE="disable"

# ========================================================
cd $(dirname $0)
. ./config.conf
# ========================================================
ABS_DOCUMENT_ROOT=$(cd ${DOCUMENT_ROOT} && pwd)
ABS_ROOT=$(pwd)
# ========================================================
APACHE_PID_FILE=${ABS_ROOT}/httpd.pid
APACHE_SIGWINCH=${ABS_ROOT}/__sig_winch__
# ========================================================

# ====== REBOOT? =======
if [ -f "${APACHE_PID_FILE}" ]
then
	PID=$(cat ${APACHE_PID_FILE})
	echo "httpd (pid ${PID}) already running"
	echo -n "Reboot?(y/N) "
	read REBOOT

	if [ "${REBOOT}" = "y" ]
	then
		./apache-stop.sh
	else
		exit 0
	fi
fi
# ====== /REBOOT? =======

# ====== SSL Check ======
ABS_SSL_CERT=""
ABS_SSL_CHAIN=""
ABS_SSL_KEY=""
VHOSTS_CONF="httpd-vhosts.conf"
if [ "${SERVER_SSL}" = "On" ]
then
  ABS_CERT_ROOT=$( cd "${SSL_PATH}" && pwd )
  if [ -f "${ABS_CERT_ROOT}/${SSL_CERT}" -a -f "${ABS_CERT_ROOT}/${SSL_CHAIN}" -a -f "${ABS_CERT_ROOT}/${SSL_KEY}" ]
    then
    ABS_SSL_CERT=${ABS_CERT_ROOT}/${SSL_CERT}
    ABS_SSL_CHAIN=${ABS_CERT_ROOT}/${SSL_CHAIN}
    ABS_SSL_KEY=${ABS_CERT_ROOT}/${SSL_KEY}
    VHOSTS_CONF="httpd-ssl-vhosts.conf"
  else
    SERVER_SSL=Off
    echo "SSL設定に必要なファイルが足りません"
  fi
fi
# ====== /SSL Check ======

HTTPD_ENV=""
if [ "$XDEBUG" = "3" ]; then
  HTTPD_ENV="XDEBUG_MODE=debug"
fi

touch $APACHE_SIGWINCH

trap 'echo "... Received SIGTERM";' 15
trap 'echo "... Received SIGWINCH"; touch $APACHE_SIGWINCH' 28

while [ -f $APACHE_SIGWINCH ]; do
  echo "... Spawning httpd in foreground ..."
  rm $APACHE_SIGWINCH

  if [ "${SERVER_PORT}" = "443" ]; then
    URL="https://${SERVER_NAME}/"
  elif [ "${SERVER_PORT}" = "80" ]; then
    URL="http://${SERVER_NAME}/"
  else
    URL="http://${SERVER_NAME}:${SERVER_PORT}/"
  fi

  if [ "${SERVER_IP}" = "" ]; then
    SERVER_IP=$SERVER_NAME
  fi

  echo ""
  echo "  $URL"
  echo ""
  echo "  ${ABS_ROOT}/etc/httpd.conf"
  echo ""
  echo "APACHE_SERVER_IP       = ${SERVER_IP}"
  echo "APACHE_SERVER_PORT     = ${SERVER_PORT}"
  echo "APACHE_SERVER_NAME     = ${SERVER_NAME}"
  echo "APACHE_DOCUMENT_ROOT   = ${ABS_DOCUMENT_ROOT}"
  echo "APACHE_SCRIPT_ROOT     = ${ABS_ROOT}"
  echo "APACHE_PID_FILE        = ${APACHE_PID_FILE}"
  if [ "${SERVER_SSL}" = "On" ] ; then
    echo "SSL_CERT               = ${ABS_SSL_CERT}"
    echo "SSL_CHAIN              = ${ABS_SSL_CHAIN}"
    echo "SSL_KEY                = ${ABS_SSL_KEY}"
  fi
  echo "PHP_MODULE_PATH        = ${PHP_MODULE_PATH}"
  echo "PHP_APACHE_MODULE_KEY  = ${PHP_APACHE_MODULE_KEY}"
  echo "XDEBUG                 = ${XDEBUG}"
  echo "XDEBUG_REMOTE_HOST     = ${XDEBUG_REMOTE_HOST}"
  echo "XDEBUG_REMOTE_PORT     = ${XDEBUG_REMOTE_PORT}"
  echo "XDEBUG_IDEKEY          = ${XDEBUG_IDEKEY}"
  echo ""
  echo $HTTPD_ENV
  echo "..."

  env \
    APACHE_SERVER_IP=${SERVER_IP} \
    APACHE_SERVER_PORT=${SERVER_PORT} \
    APACHE_SERVER_NAME=${SERVER_NAME} \
    APACHE_DOCUMENT_ROOT=${ABS_DOCUMENT_ROOT} \
    APACHE_SCRIPT_ROOT=${ABS_ROOT} \
    APACHE_PID_FILE=${APACHE_PID_FILE} \
    USE_SSL=${SERVER_SSL} \
    SSL_CERT=${ABS_SSL_CERT} \
    SSL_CHAIN=${ABS_SSL_CHAIN} \
    SSL_KEY=${ABS_SSL_KEY} \
    APACHE_VHOSTS_CONF=${VHOSTS_CONF} \
    PHP_MODULE_PATH=${PHP_MODULE_PATH} \
    PHP_APACHE_MODULE_KEY=${PHP_APACHE_MODULE_KEY} \
    XDEBUG=${XDEBUG} \
    XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST} \
    XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT} \
    XDEBUG_IDEKEY=${XDEBUG_IDEKEY} \
    $HTTPD_ENV \
    $APACHE -f ${ABS_ROOT}/etc/httpd.conf -DFOREGROUND | perl ./etc/apache-logfilter.pl
done
