#!/bin/sh
# ===================================================================
#  Standalone PHP7.x-CLI + Xdebug on foreground process for HomeBrew
# ===================================================================
if [ "$1" = "" ]
then
  echo "Usage: $0 [filename.php] {args...}"
  exit
fi

# =====================
#  Include config.conf
# =====================
. $(dirname $0)/config.conf

if [ ! -x "$PHP7" ]
then
  echo "Not executable file, ${PHP7}"
  exit
fi

# =====================
#  Make params
# =====================
PHP_OPTS=()
PHP_OPTS+=("-d include_path=${PHP_INCLUDE_PATH}")

if [ "${XDEBUG2}" = "on" ]; then
  PHP_OPTS+=("-d xdebug.remote_enable=on")
  PHP_OPTS+=("-d xdebug.remote_autostart=on")
  PHP_OPTS+=("-d xdebug.remote_host=${XDEBUG2_REMOTE_HOST}")
  PHP_OPTS+=("-d xdebug.remote_port=${XDEBUG2_REMOTE_PORT}")
  PHP_OPTS+=("-d xdebug.idekey=${XDEBUG2_IDEKEY}")
fi

if [ "${XDEBUG3}" = "on" ]; then
  PHP_OPTS+=("-d xdebug.mode=debug")
  PHP_OPTS+=("-d xdebug.start_with_request=yes")
  PHP_OPTS+=("-d xdebug.client_host=${XDEBUG3_CLIENT_HOST}")
  PHP_OPTS+=("-d xdebug.client_port=${XDEBUG3_CLIENT_PORT}")
  PHP_OPTS+=("-d xdebug.idekey=${XDEBUG3_IDEKEY}")
fi

# =====================
#  Execute PHP script
# =====================
$PHP7 ${PHP_OPTS[@]} $*
