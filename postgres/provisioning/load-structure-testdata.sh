#!/bin/sh
#crash on everything but no -x as we do not want to display passwords in the log
set -e
#make sure we catch pipe failures
set -o pipefail

if [[ ${MYSQL_ROOT_PASSWORD} == "" ]]; then
	echo "Missing MYSQL_ROOT_PASSWORD env variable"
	exit 1
fi
if [[ ${MYSQL_DATABASE} == "" ]]; then
	echo "Missing MYSQL_DATABASE env variable"
	exit 1
fi
echo "loading in users"
cat /docker-entrypoint/01-users.sql         | mysql --user="root" --password="${MYSQL_ROOT_PASSWORD}" --host="mysql"
echo "command exited with code $?..now loading in structure"

exitcode=$?
echo "command exited with code $exitcode ..now EOS"
exit $exitcode