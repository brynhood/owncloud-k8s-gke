export MYSQLVERSION=0.1
export REDISVERSION=0.1
export OWNCLOUDVERSION=0.1
export NAMESPACE=prod

if [ "$NAMESPACE" == "test" ]; then
    echo -e "\033[0;35m";
    export BACKUPSCHEDULE="@daily"
    export MEMREQ_LISTING="80M"
    export MEMLIMIT_LISTING="200M"
    export MEMREQ_MYSQL="200M"
    export MEMLIMIT_MYSQL="350M"
else
    echo -e "\033[0;31m";
    export BACKUPSCHEDULE="0 */4 * * *"
    export MEMREQ_LISTING="120M"
    export MEMLIMIT_LISTING="400M"
    export MEMREQ_MYSQL="450M"
    export MEMLIMIT_MYSQL="750M"
fi

export LOCALHEALTH="http://localhost"
export REMOTEHEALTH="http://www.google.be"
export REMOTEINDEX="http://www.google.be"
export REMOTEMETRICS="http://www.google.be"
export RELEASENAME="owncloud"