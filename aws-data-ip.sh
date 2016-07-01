# Lookup the UP address for the Test Database environment (eg ETL testing)

export https_proxy="https://proxy.mgmt.prod.dvsa.aws:3128"
aws ec2 describe-instances --region eu-west-1 --query 'Reservations[].Instances[].{IP:PrivateIpAddress}' --filter Name=tag:Name,Values="APP/NDU/INT-OLCS-PRI-API-EC2-TEST"
#aws ec2 describe-instances --region eu-west-1 --filter Name=tag:Name,Values="APP/NDU/INT-OLCS-PRI-API-EC2-TEST"
