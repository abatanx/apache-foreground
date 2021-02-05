#!/bin/sh

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

if [ -f "${APACHE_PID_FILE}" ]
then
	echo "... Stopping httpd ..."
	PID=$(cat "${APACHE_PID_FILE}")

	touch $APACHE_IGNORE_REBOOT
	kill -TERM ${PID}
fi
