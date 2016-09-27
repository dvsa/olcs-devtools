#!/usr/bin/env bash

echo
echo SSH to an AWS box
echo Version 1.0.3
echo

if [[ $(hostname) == *"nonprod"* ]]; then
  # NON-PROD Proxy
  export https_proxy="https://proxy.devmgmt.nonprod.dvsa.aws:3128"
else
  # PROD proxy
  export https_proxy="https://proxy.mgmt.prod.dvsa.aws:3128"
fi

if [ -z $https_proxy ]; then
	echo "'https_proxy' environment variables is not set!!"
	exit 1;
fi

while getopts "r:e:n:" opt; do
  case $opt in
    r)
      role=${OPTARG^^}
      ;;
    e)
      case ${OPTARG^^} in
        "PROD")
          env="APP"
          ;;
        "PRE")
          env="APP/PP"
          ;;
        "INT")
          env="APP/NDU/INT"
          ;;
        "DEV")
          env="DEV/APP/DEV"
          ;;
        "DEMO")
          env="DEV/APP/DEMO"
          ;;
        "POC")
          env="DEV/APP/POC"
          ;;
        "QA")
          env="DEV/APP/QA"
          ;;
        "DA")
          env="DEV/APP/DA"
          ;;
        "REG")
          env="DEV/APP/REG"
          ;;
      esac
      ;;
    n)
      n=${OPTARG^^}
      ;;
  esac
done

if [ -z $role ]; then
	echo "Role not specified, use -r <role>"
	echo "
    ADDRESS   (AddressBase)
    API       (OLCS Backend)
    BASTION   (Bastion)
    CPMSA     (CPMS API Tier)
    CPMSPROXY (CPMS Reverse Proxies)
    CPMSW     (CPMS Web Tier)
    DIR       (OpenDJ Tier)
    DOCMAN    (FileStore API Tier)
    FILE      (Samba Tier)
    IUAP1     (IU OpenAM Web Agent Proxy Tier 1)
    IUAP2     (IU OpenAM Web Agent Proxy Tier 2)
    IUAUTH    (IU OpenAM Tier)
    IUWEB     (IU Web Tier)
    NFS       (Gluster Tier)
    PRINT     (CUPS Tier)
    REPORTS   (Jasper Reports Tier)
    SEARCH    (OLCS ElasticSearch Tier)
    SSAP1     (SS OpenAM Web Agent Proxy Tier 1)
    SSAP2     (SS OpenAM Web Agent Proxy Tier 2)
    SSAUTH    (SS OpenAM Tier)
    SSWEB     (SS Web Tier)
"
	exit;
fi

if [ -z $env ]; then
        echo "Environment not found, use -e <PROD|PRE|INT|DEV|DEMO|POC|QA|DA|REG>"
        echo "
    Prod AWS
        PROD = APP (Production)
        PRE  = APP/PP (Pre-Prod)
        INT  = APP/NDU/INT (Integration)
    Non-Prod AWS
        DEV  = DEV/APP/DEV (Development)
        DEMO = DEV/APP/DEMO (Demo)
        POC  = DEV/APP/POC (PoC)
        QA   = DEV/APP/QA (QA)
        DA   = DEV/APP/DA (DA)
        REG  = DEV/APP/REG (Regression)
"
        exit;
fi

if [ -z $n ]; then
    # if not specified default to first box found
    n=1
fi

echo "Role = $role"
echo "Environment = $env"
echo "Number = $n"

ip=$(aws ec2 describe-instances --region eu-west-1 \
--query 'Reservations[].Instances[].{IP:PrivateIpAddress}' \
--filter Name=tag:Role,Values="$role" Name=tag:Environment,Values="$env" \
| grep -o "10.[0-9\.]*" -m$n | tail -1)

echo "IP = $ip"

ssh $ip
