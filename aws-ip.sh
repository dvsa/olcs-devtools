echo
echo Lookup AWS IPs v 1.0
echo

export https_proxy="https://proxy.mgmt.prod.dvsa.aws:3128"

while getopts "r:e:" opt; do
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
	esac
      ;;
  esac
done

if [ -z $role ]; then
	echo "Role not specified, use -r <role>"
	echo "
·         ADDRESS (AddressBase)
·         API (OLCS Backend)
·         BASTION (Bastion)
·         CPMSA (CPMS API Tier)
·         CPMSPROXY (CPMS Reverse Proxies)
·         CPMSW (CPMS Web Tier)
·         DIR (OpenDJ Tier)
·         DOCMAN (FileStore API Tier)
·         FILE (Samba Tier)
·         IUAP1 (IU OpenAM Web Agent Proxy Tier 1)
·         IUAP2 (IU OpenAM Web Agent Proxy Tier 2)
·         IUAUTH (IU OpenAM Tier)
·         IUWEB (IU Web Tier)
·         NFS (Gluster Tier)
·         PRINT (CUPS Tier)
·         REPORTS (Jasper Reports Tier)
·         SEARCH (OLCS ElasticSearch Tier)
·         SSAP1 (SS OpenAM Web Agent Proxy Tier 1)
·         SSAP2 (SS OpenAM Web Agent Proxy Tier 2)
·         SSAUTH (SS OpenAM Tier)
·         SSWEB (SS Web Tier)
"

	exit;
fi

if [ -z $env ]; then
        echo "Environment not found, use -e <PROD|PRE|INT>"
        exit;
fi


echo "Role = $role"
echo "Environment = $env"

aws ec2 describe-instances --region eu-west-1 \
--query 'Reservations[].Instances[].{IP:PrivateIpAddress}' \
--filter Name=tag:Role,Values="$role" Name=tag:Environment,Values="$env"

echo
