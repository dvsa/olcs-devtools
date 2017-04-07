#!/usr/bin/env bash

#echo
#echo Lookup AWS IPs
#echo Version 1.0.3
#echo

usage() {
    if [ -n "$1" ]; then
        echo;
        echo "Error : $1"
        echo
    fi
    echo "Usage:"
    echo "  aws-ip.sh -r <role> -e <environment> [-n <instance number>] [-h]"
    echo
    echo "Options:"
    echo "  -h Show usage information (this screen)"
    echo "  -n Instance number to connect to. Eg 1 = first found instance, 2 = second, etc"
    echo "  -r Role, one of:
        ADDRESS    AddressBase
        API        OLCS Backend
        BASTION    Bastion
        CPMSAPI    CPMS API Tier
        CPMSPROXY  CPMS Reverse Proxies
        CPMSW      CPMS Web Tier
        DIR        OpenDJ Tier
        DOCMAN     FileStore API Tier
        FILE       Samba Tier
        IUAP1      IU OpenAM Web Agent Proxy Tier 1
        IUAP2      IU OpenAM Web Agent Proxy Tier 2
        IUAUTH     IU OpenAM Tier
        IUWEB      IU Web Tier
        NFS        Gluster Tier
        PRINT      CUPS Tier
        REPORTS    Jasper Reports Tier
        SEARCH     OLCS ElasticSearch Tier
        SEARCHDATA OLCS Logstash
        SSAP1      SS OpenAM Web Agent Proxy Tier 1
        SSAP2      SS OpenAM Web Agent Proxy Tier 2
        SSAUTH     SS OpenAM Tier
        SSWEB      SS Web Tier
        MATCH      Verify Matching Service"
    echo "  -e Environment, one of:
        PROD      APP (Production)
        PRE       APP/PP (Pre-Prod)
        INT       APP/NDU/INT (Integration)
        DEV       DEV/APP/DEV (Development)
        DEMO      DEV/APP/DEMO (Demo)
        POC       DEV/APP/POC (PoC)
        QA        DEV/APP/QA (QA)
        REG       DEV/APP/REG (Regression)
        CI        DEV/APP/CI (CI Jenkins)"
	exit 2;
}

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

while getopts "r:e:n:h" opt; do
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
        "CI")
          env="DEV/APP/CI"
          ;;
      esac
      ;;
    n)
      n=${OPTARG^^}
      ;;
    h)
      usage
      ;;
  esac
done

if [ -z $role ]; then
	usage "Role must be specified with -r"
fi

if [ -z $env ]; then
  usage "Environment must be specified with -e"
fi

#echo "Role = $role"
#echo "Environment = $env"

IPS=$(aws ec2 describe-instances --region eu-west-1 \
--query 'Reservations[].Instances[].{IP:PrivateIpAddress}' \
--filter Name=tag:Role,Values="$role" Name=tag:Environment,Values="$env" \
| grep "IP" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")

if [ -z $n ]; then
  # Echo All the IPs
  echo "$IPS"
else
  # Echo just IP number n
  echo "$IPS" | sed -n "$n"p
fi