#!/bin/bash
#crash on everything but no -x as we do not want to display passwords in the log
set -e
#make sure we catch pipe failures
set -o pipefail

export SHELLVARSCLEAR="`printf '${%s} ' $(sh -c "env|cut -d'=' -f1")`"
export SHELLVARS=`printf "'%s'" "${SHELLVARSCLEAR//\'/\'\\\'\'};"`

echo "going into work with $SHELLVARS from $SHELLVARSCLEAR"

#make sure all our template files are being set correctly
cd /templates
for i in `ls *`
    do /bin/bash -c "envsubst $SHELLVARS < $i > /docker-entrypoint/$i"
done

#start up the env var start script
$STARTSCRIPT
exitcode=$?
echo "END OF STARTSCRIPT with exitcode $exitcode"
exit $exitcode