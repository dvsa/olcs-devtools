#!/bin/bash
IFS=
set -e
SETUP=$1
echo $SETUP
#warnign dangerous ARG used for development ease only
if [ $SETUP == 'CLEAN' ]
 then
    `rm -rf ../zf3`
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
    for i in "${repos[@]}"
    do
	    git clone $i
    done
fi

#git vol-each checkout -B project/zf3-upgrade
VAGRANTFILE="../infrastructure/Vagrantfile"

declare -a hosts=(
        ''
        '192.168.149.133 zf3-olcs-internal zf3-selfserve zf3-olcs-backend zf3-olcs-ebsr zf3-olcs-nr'
        '192.168.149.211 zf3-olcs-internal.olcs.gov.uk'
        '192.168.149.212 zf3-olcs-selfserve.olcs.gov.uk'
        '192.168.149.213 zf3-olcs-backend.olcs.gov.uk'
)

printf "%s\n" "${hosts[@]}" >> "../infrastructure/olcs/files/etc/hosts"

#
authProvisionLine=`grep -n "#dynamic_zf3_provisioning" $VAGRANTFILE | cut -d: -f 1`
authProvisionLine=$(($authProvisionLine+1))

for i in "${!hosts[@]}"; do
   INCLUDE="NR=="$(($i+$authProvisionLine))
   #echo $INCLUDE
   echo "`awk $INCLUDE'{print "echo \42 '${hosts[$i]}'\42 >>/etc/hosts"}1' $VAGRANTFILE`" > $VAGRANTFILE

done

authProvisionLine=`grep -n "# end dynamic zf3 network" $VAGRANTFILE | cut -d: -f 1`
authProvisionLine=$(($authProvisionLine-1))
INCLUDE="NR=="$authProvisionLine

echo $INCLUDE

echo "`awk $INCLUDE'{print " olcs_auth.vm.network \42private_network\42, ip: \42 192.168.149.210\42 "}1' $VAGRANTFILE`" > $VAGRANTFILE
INCLUDE="NR=="$(($authProvisionLine+1))
echo "`awk $INCLUDE'{print " olcs_auth.vm.network \42private_network\42, ip: \42 192.168.149.211\42 "}1' $VAGRANTFILE`" > $VAGRANTFILE
INCLUDE="NR=="$(($authProvisionLine+2))
echo "`awk $INCLUDE'{print " olcs_auth.vm.network \42private_network\42, ip: \42 192.168.149.212\42 "}1' $VAGRANTFILE`" > $VAGRANTFILE
INCLUDE="NR=="$(($authProvisionLine+3))
echo "`awk $INCLUDE'{print " olcs_auth.vm.network \42private_network\42, ip: \42 192.168.149.213\42 "}1' $VAGRANTFILE`" > $VAGRANTFILE






STARTCOMMENT="# start olcs_v2"
ENDCOMMENT="# end olcs_v2"

vm=`sed -n "/$STARTCOMMENT/,/$ENDCOMMENT/p" $VAGRANTFILE`
vm=$(echo "$vm" | sed "s/olcs_v2/olcs_v3/g")
vm=$(echo "$vm" | sed "s/'olcs-v2'/'olcs-v3'/g")
vm=$(echo "$vm" | sed "s/mounts.yaml/mounts-zf3.yaml/g")
vm=$(echo "$vm" | sed "s/:zf2/:zf3/g")
vm=$(echo "$vm" | sed "s/host: 8080/host: 8085/g")
#vm=$(echo "$vm" | sed "s/virtualhosts.yaml/virtualhosts-zf3.yaml/g")
vm=$(echo "$vm" | sed "s/zf2/zf3/g")

COMMENT=`grep -n "$ENDCOMMENT" $VAGRANTFILE | cut -d: -f 1`
COMMENT=$(($COMMENT+1))

ZF3Vagrant=$VAGRANTFILE"-ZF3"
echo $vm > $ZF3Vagrant
ZF3Vagrant="\'../Vagrantfile-ZF3\'"

INCLUDE="NR=="$COMMENT
INCLUDE2="NR=="$(($COMMENT+1))
echo $INCLUDE2
echo "`awk $INCLUDE'{print " zf3_vagrant = File.expand_path('$ZF3Vagrant',__FILE__)"}1' $VAGRANTFILE`" > $VAGRANTFILE
echo "`awk $INCLUDE2'{print "eval File.read(zf3_vagrant)  if File.exists?(zf3_vagrant)"}1' $VAGRANTFILE`" > $VAGRANTFILE

