#!/bin/bash

###############################################################################
# Build Kubernetes yaml files and do the deploy
#
# set versions
###############################################################################
export MYSQLVERSION=0.22
export PROMETHEUSVERSION=0.4
export GRAFANAVERSION=0.10
export REDISVERSION=0.1

export LISTINGVERSION=2.45
export NAMESPACE=test

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
###############################
# end versions
###############################

#############################
# check local code status
#############################
echo -n "testing local git: "
countdiff=`git status --porcelain=2 | wc -l`
if [ $countdiff -gt 1 ]; then
    echo ""
    echo "#######################################################################################"
    echo "lots of changes here: $countdiff...did you forget to commit your stuff?"
    echo "#######################################################################################"

    sleep 10
else
    echo "ok: $countdiff"
    git push
fi
###############################
# preflight check your docker
###############################
if [ "$1" != "skip" ]; then
    #curl call to localhost container should give 200
    echo -n "testing local container status: "
    retcode="$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/health.php?gsuite=1&errors=1)"
    if [ $retcode -ne 200 ]; then
        echo "I got exit code $retcode...so exiting"
        exit -1;
    else
        echo "ok -> $retcode"
    fi
fi


#############################
# run deploy run!
#############################

echo "releasing to $NAMESPACE of version $LISTINGVERSION"
echo -e "\033[0m"
git tag release-listing-$LISTINGVERSION
git push --tags
if [ "$1" != "skip" ]; then
    echo -n "sleeping"
    for i in `seq 1 130`;do
        sleep 1
        echo -n "."
    done
    echo "awake you soldiers! Let's deploy"
fi

BUILD_DIR='./assembled'
rm assembled/*.yaml
K8S_DIR='./deployments'
FINDCMD="find $K8S_DIR -print0 -type f -iname '*.yaml'"

export SHELLVARSCLEAR="`printf '${%s} ' $(sh -c "env|cut -d'=' -f1")`"
export SHELLVARS=`printf "'%s'" "${SHELLVARSCLEAR//\'/\'\\\'\'};"`

#echo "going into work with $SHELLVARS from $SHELLVARSCLEAR"

echo "building yaml with build DIR " $BUILD_DIR " K8S_DIR " $K8S_DIR " with find cmd " $FINDCMD

$FINDCMD | while read -d $'\0' file; do
    mkdir -p $BUILD_DIR
    if [ -f $file ]; then
        #apapt our templates for prod and dev
        BASENAME=$(basename $file)
        /bin/bash -c "envsubst $SHELLVARS < $file > $BUILD_DIR/$BASENAME"
    fi
done
echo "deploying...to $NAMESPACE"
sleep 3
for i in `ls $BUILD_DIR`; do
    kubectl --namespace=$NAMESPACE apply -f $BUILD_DIR/$i
done
kubectl --namespace=$NAMESPACE get deployment
echo "sleeping now for second get"
sleep 40
kubectl --namespace=$NAMESPACE get deployment

if [ "$NAMESPACE" == "test" ]; then
    host='testlisting' 
else
    host='listing'
fi 
retcode="$(curl -s -o /dev/null -w '%{http_code}' https://$host.europascouts.be/health.php)"
retIndex="$(curl -s -o /dev/null -w '%{http_code}' https://$host.europascouts.be/index.php)"
retMetrics="$(curl -s -o /dev/null -w '%{http_code}' https://$host.europascouts.be/health.php?gsuite=1&errors=1)"

date="$(date)"
echo -e "host tested is $host: \n   health is:\t $retcode\n   index is:\t $retIndex\n   metrics is:\t $retMetrics\n all good..bye...clocking of at $date"