#!/bin/bash
IFS=
set -e
SETUP=$1
#warnign dangerous ARG used for development ease only
if [ $SETUP='CLEAN' ]
 then
    `rm -rf ../zf3`
fi

mkdir ../zf3
cd ../zf3

declare -a repos=(
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/companies-house.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-auth.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-autoload.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-backend.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-ci.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-common.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-config.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-devtools.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-elasticsearch.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-etl.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-internal.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-logging.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-oa.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-plugins.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-reporting.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-selfserve.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-static.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-templates.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-testhelpers.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-transfer.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-txc.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-utils.git'
        )

#for i in "${repos[@]}"
#do
#	git clone $i
#done
STARTCOMMENT="# start olcs_v2"
ENDCOMMENT="# end olcs_v2"
VAGRANTFILE="../infrastructure/Vagrantfile"
vm=`sed -n "/$STARTCOMMENT/,/$ENDCOMMENT/p" $VAGRANTFILE`
vm=$(echo "$vm" | sed "s/olcs_v2/olcs_v3/g")
vm=$(echo "$vm" | sed "s/'olcs-v2'/'olcs-v3'/g")

COMMENT=`grep -n "$ENDCOMMENT" $VAGRANTFILE | cut -d: -f 1`
COMMENT=$(($COMMENT+1))

ZF3Vagrant=$VAGRANTFILE"-ZF3"
echo $vm > $ZF3Vagrant
ZF3Vagrant="\'../Vagrantfile-ZF3\'"
# server_vagrantfile = File.expand_path('../vagrant/Vagrantfile.server', __FILE__)
# eval File.read(server_vagrantfile) if File.exists?(server_vagrantfile)
echo "updating Vagrant file at line $COMMENT"
INCLUDE="NR=="$COMMENT
INCLUDE2="NR=="$(($COMMENT+1))
echo $INCLUDE2
echo "`awk $INCLUDE'{print " zf3_vagrant = File.expand_path('$ZF3Vagrant',__FILE__)"}1' $VAGRANTFILE`" > $VAGRANTFILE
echo "`awk $INCLUDE2'{print "eval File.read(zf3_vagrant)  if File.exists?(zf3_vagrant)"}1' $VAGRANTFILE`" > $VAGRANTFILE